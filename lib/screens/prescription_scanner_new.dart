import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import '../services/vision_service.dart';
import '../services/gemini_service.dart';
import '../services/local_storage_service.dart';
import '../models/prescription_history.dart';
import '../utils/app_theme.dart';
import '../widgets/modern_components.dart';
import '../utils/helpers.dart';
import 'results_screen.dart';

class PrescriptionScannerNew extends StatefulWidget {
  const PrescriptionScannerNew({super.key});

  @override
  State<PrescriptionScannerNew> createState() => _PrescriptionScannerNewState();
}

class _PrescriptionScannerNewState extends State<PrescriptionScannerNew>
    with TickerProviderStateMixin {
  final ImagePicker _picker = ImagePicker();
  final VisionService _visionService = VisionService();
  final GeminiService _geminiService = GeminiService();
  final LocalStorageService _storageService = LocalStorageService();

  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  File? _selectedImage;
  bool _isProcessing = false;
  bool _isCameraReady = false;
  bool _useFrontCamera = false;
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeController.forward();
    _initializeCameras();
  }

  Future<void> _initializeCameras() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _initializeCamera(_cameras![0]);
      }
    } catch (e) {
      _showError('Failed to initialize camera: $e');
    }
  }

  void _initializeCamera(CameraDescription camera) async {
    _cameraController = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _cameraController!.initialize();
      if (mounted) {
        setState(() {
          _isCameraReady = true;
        });
      }
    } catch (e) {
      _showError('Failed to initialize camera: $e');
    }
  }

  void _toggleCamera() {
    if (_cameras == null || _cameras!.length < 2) return;

    setState(() {
      _useFrontCamera = !_useFrontCamera;
    });

    final selectedCamera = _useFrontCamera ? _cameras![1] : _cameras![0];
    _cameraController?.dispose();
    _initializeCamera(selectedCamera);
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final image = await _cameraController!.takePicture();
      setState(() {
        _selectedImage = File(image.path);
      });
      _processImage();
    } catch (e) {
      _showError('Failed to capture image: $e');
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        _processImage();
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  Future<void> _processImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      // Step 1: Extract text using ML Kit
      final String extractedText =
          await _visionService.extractTextFromImage(_selectedImage!);

      if (extractedText.isEmpty) {
        _showError('No text found in image. Please try a clearer image.');
        setState(() {
          _isProcessing = false;
          _selectedImage = null;
        });
        return;
      }

      // Step 2: Use Gemini to structure and explain the prescription
      final String analyzedText =
          await _geminiService.analyzePrescription(extractedText);

      // Step 3: Save to history
      final prescription = PrescriptionHistory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _generateTitle(extractedText),
        scanDate: DateTime.now(),
        extractedText: extractedText,
        analyzedText: analyzedText,
        imagePath: _selectedImage!.path,
      );

      await _storageService.savePrescription(prescription);

      // Step 4: Navigate to results
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsScreen(
            originalText: extractedText,
            analyzedText: analyzedText,
            imagePath: _selectedImage!.path,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showError('Error processing image: $e');
      setState(() {
        _isProcessing = false;
        _selectedImage = null;
      });
    }
  }

  String _generateTitle(String extractedText) {
    final lines = extractedText.split('\n');
    for (final line in lines) {
      if (line.trim().isNotEmpty && line.length > 5) {
        return 'Prescription: ${Helpers.truncateText(line.trim(), maxLength: 30)}';
      }
    }
    return 'Prescription ${Helpers.formatDate(DateTime.now())}';
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.dangerColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: _isProcessing
          ? _buildProcessingScreen()
          : _selectedImage != null
              ? _buildImagePreviewScreen()
              : _isCameraReady
                  ? _buildCameraScreen()
                  : _buildLoadingScreen(),
    );
  }

  Widget _buildLoadingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppTheme.primaryGradientStart,
          ),
          const SizedBox(height: 16),
          Text(
            'Initializing Camera...',
            style: Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryGradientStart.withOpacity(0.2),
                  AppTheme.primaryGradientEnd.withOpacity(0.2),
                ],
              ),
            ),
            child: CircularProgressIndicator(
              color: AppTheme.primaryGradientStart,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Processing Prescription...',
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Extracting text and analyzing medication...',
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraScreen() {
    return SafeArea(
      child: Stack(
        children: [
          // Camera Preview
          SizedBox.expand(
            child: CameraPreview(_cameraController!),
          ),

          // Gradient Overlay on bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 200,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ),

          // Header with close button
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'Scan Prescription',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(color: Colors.white),
                  ),
                  IconButton(
                    icon: const Icon(Icons.flip_camera_ios_rounded,
                        color: Colors.white),
                    onPressed: _toggleCamera,
                  ),
                ],
              ),
            ),
          ),

          // Focus indicator
          Center(
            child: Container(
              width: 250,
              height: 350,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppTheme.accentColor.withOpacity(0.6),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Position prescription\nwithin frame',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: AppTheme.accentColor.withOpacity(0.8),
                        ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Control Buttons
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Gallery Button
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.photo_library_rounded),
                      color: Colors.white,
                      onPressed: _pickImageFromGallery,
                    ),
                  ),

                  // Capture Button
                  GestureDetector(
                    onTap: _capturePhoto,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryGradientStart,
                            AppTheme.primaryGradientEnd,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryGradientStart.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 4,
                          ),
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ),

                  // Placeholder for symmetry
                  Container(
                    width: 50,
                    height: 50,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreviewScreen() {
    return SafeArea(
      child: Stack(
        children: [
          // Image
          SizedBox.expand(
            child: Image.file(
              _selectedImage!,
              fit: BoxFit.cover,
            ),
          ),

          // Semi-transparent overlay
          Container(
            color: Colors.black.withOpacity(0.3),
          ),

          // Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white),
                    onPressed: () => setState(() => _selectedImage = null),
                  ),
                  Text(
                    'Review Image',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(color: Colors.white),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),

          // Bottom Controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Is this prescription clear?',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(() => _selectedImage = null),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            side: const BorderSide(
                              color: Colors.white,
                              width: 2,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'Retake',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GradientButton(
                          label: 'Process',
                          icon: Icons.check_rounded,
                          onPressed: _processImage,
                          fullWidth: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
