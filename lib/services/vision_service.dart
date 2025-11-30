import 'dart:io';
import 'package:google_ml_kit/google_ml_kit.dart';

class VisionService {
  // The current project depends on `google_ml_kit` which exposes
  // `textRecognizer()` but that API is flagged deprecated by the
  // analyzer. Keep using it for now and suppress the deprecation
  // warning until a migration to the newer `google_mlkit_text_recognition`
  // package is completed.
  // ignore: deprecated_member_use
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