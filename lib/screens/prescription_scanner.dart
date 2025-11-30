import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/vision_service.dart';
import '../services/gemini_service.dart';
import '../services/local_storage_service.dart';
import '../models/prescription_history.dart';
import 'results_screen.dart';
import '../utils/helpers.dart';

class PrescriptionScanner extends StatefulWidget {
  const PrescriptionScanner({super.key});

  @override
  State<PrescriptionScanner> createState() => _PrescriptionScannerState();
}

class _PrescriptionScannerState extends State<PrescriptionScanner> {
  final ImagePicker _picker = ImagePicker();
  final VisionService _visionService = VisionService();
  final GeminiService _geminiService = GeminiService();
  final LocalStorageService _storageService = LocalStorageService();
  
  File? _selectedImage;
  bool _isProcessing = false;

  Future<void> _pickImage() async {
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
      // Step 1: Extract text using our service
      final String extractedText = await _visionService.extractTextFromImage(_selectedImage!);
      
      // Step 2: Use Gemini to structure and explain the prescription
      final String analyzedText = await _geminiService.analyzePrescription(extractedText);
      
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
      Navigator.push(
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
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
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
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Prescription'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Instructions
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Icon(Icons.photo_camera, size: 40, color: Colors.green),
                    SizedBox(height: 10),
                    Text(
                      'Upload Prescription Image',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Select a clear image of your prescription from gallery',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            
            // Image Preview or Placeholder
            Expanded(
              child: _selectedImage == null
                  ? Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.photo_library, size: 60, color: Colors.grey),
                          SizedBox(height: 10),
                          Text('No image selected'),
                        ],
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(_selectedImage!),
                    ),
            ),
            const SizedBox(height: 30),
            
            // Action Button
            if (_isProcessing)
              const Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text('Processing image...'),
                ],
              )
            else
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo_library),
                label: const Text('Select from Gallery'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
              ),
          ],
        ),
      ),
    );
  }
}