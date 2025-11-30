import 'package:flutter/material.dart';
import '../widgets/medicine_card.dart';

class ResultsScreen extends StatefulWidget {
  final String originalText;
  final String analyzedText;
  final String imagePath;

  const ResultsScreen({
    super.key,
    required this.originalText,
    required this.analyzedText,
    required this.imagePath,
  });

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Results'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Tab Selection
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTabButton('Extracted Text', 0),
                  ),
                  Expanded(
                    child: _buildTabButton('AI Analysis', 1),
                  ),
                ],
              ),
            ),
          ),
          
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _selectedTab == 0
                  ? _buildOriginalText()
                  : _buildAnalyzedText(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String text, int index) {
    return TextButton(
      onPressed: () {
        setState(() {
          _selectedTab = index;
        });
      },
      style: TextButton.styleFrom(
        backgroundColor: _selectedTab == index ? Colors.blue : Colors.transparent,
        foregroundColor: _selectedTab == index ? Colors.white : Colors.blue,
      ),
      child: Text(text),
    );
  }

  Widget _buildOriginalText() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Extracted Text from Image:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                widget.originalText.isEmpty ? 'No text detected' : widget.originalText,
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyzedText() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AI Analysis:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Card(
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.medical_information, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'AI-Powered Explanation',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.analyzedText,
                    style: const TextStyle(fontSize: 14, height: 1.4),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    '⚠️ Important: This is an AI-assisted explanation. Always consult with a healthcare professional for medical advice.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red,
                      fontStyle: FontStyle.italic,
                    ),
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