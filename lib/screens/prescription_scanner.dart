import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/vision_service.dart';
import '../services/gemini_service.dart';
import 'results_screen.dart';

class PrescriptionScanner extends StatefulWidget {
  const PrescriptionScanner({super.key});

  @override
  State<PrescriptionScanner> createState() => _PrescriptionScannerState();
}

class _PrescriptionScannerState extends State<PrescriptionScanner> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isProcessing = false;
  final VisionService _visionService = VisionService();
  final GeminiService _geminiService = GeminiService();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
      _processImage();
    }
  }

  Future<void> _processImage() async {
    if (_selectedImage == null) return;
    
    setState(() {
      _isProcessing = true;
    });

    try {
      // Step 1: Extract text using Google Vision AI
      final String extractedText = await _visionService.extractTextFromImage(_selectedImage!);
      
      // Step 2: Use Gemini to structure and explain the prescription
      final String analyzedText = await _geminiService.analyzePrescription(extractedText);
      
      // Navigate to results screen
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error processing image: $e')),
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
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
                      'Take a clear photo of your prescription',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Ensure good lighting and focus on the text',
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
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, size: 60, color: Colors.grey),
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
              const CircularProgressIndicator()
            else
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Take Photo of Prescription'),
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