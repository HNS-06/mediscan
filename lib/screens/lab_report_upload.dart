import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/vision_service.dart';
import '../services/gemini_service.dart';
import 'results_screen.dart';

class LabReportUpload extends StatefulWidget {
  const LabReportUpload({super.key});

  @override
  State<LabReportUpload> createState() => _LabReportUploadState();
}

class _LabReportUploadState extends State<LabReportUpload> {
  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;
  bool _isProcessing = false;
  final VisionService _visionService = VisionService();
  final GeminiService _geminiService = GeminiService();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
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
      // Extract text using Google Vision AI
      final String extractedText = await _visionService.extractTextFromImage(_selectedImage!);
      
      // Use Gemini to analyze lab report
      final String analyzedText = await _geminiService.analyzeLabReport(extractedText);
      
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
        title: const Text('Upload Lab Report'),
        backgroundColor: Colors.orange[700],
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
                    Icon(Icons.assignment, size: 40, color: Colors.orange),
                    SizedBox(height: 10),
                    Text(
                      'Upload your lab report',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Take a photo or select from gallery. We\'ll help you understand the results.',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            
            // Image Preview
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
            
            // Action Buttons
            if (_isProcessing)
              const CircularProgressIndicator()
            else
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.photo_library),
                      label: const Text('From Gallery'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}