import 'dart:io';
import 'package:google_ml_kit/google_ml_kit.dart';

class VisionService {
  final TextRecognizer _textRecognizer = GoogleMlKit.vision.textRecognizer();

  Future<String> extractTextFromImage(File imageFile) async {
    try {
      final inputImage = InputImage.fromFile(imageFile);
      final RecognizedText recognizedText = await _textRecognizer.processImage(inputImage);
      
      String extractedText = '';
      for (TextBlock block in recognizedText.blocks) {
        for (TextLine line in block.lines) {
          extractedText += '${line.text}\n';
        }
      }
      
      return extractedText.trim();
    } catch (e) {
      throw Exception('Failed to extract text: $e');
    }
  }

  void dispose() {
    _textRecognizer.close();
  }
}