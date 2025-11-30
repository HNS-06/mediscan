import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  static String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent';
  
  Future<String> analyzePrescription(String extractedText) async {
    final String prompt = """
    Analyze this prescription text and provide a clear, structured explanation:

    PRESCRIPTION TEXT:
    $extractedText

    Please provide:
    1. A clean, formatted version of the prescription
    2. Explanation of each medicine's purpose in simple terms
    3. Common dosage instructions
    4. Any important warnings or side effects to watch for

    Format the response in a patient-friendly way. If the text doesn't look like a prescription, mention that.
    """;

    return _callGeminiAPI(prompt);
  }

  Future<String> analyzeLabReport(String extractedText) async {
    final String prompt = """
    Analyze this lab report text and provide a clear explanation:

    LAB REPORT TEXT:
    $extractedText

    Please provide:
    1. Summary of key findings
    2. Identification of any abnormal values (highlight if critical)
    3. Simple explanation of what each important test measures
    4. General guidance on what the results might indicate

    Format clearly and use simple language. Highlight critical abnormalities.
    Always remind to consult a doctor for proper medical interpretation.
    """;

    return _callGeminiAPI(prompt);
  }

  Future<String> _callGeminiAPI(String prompt) async {
    if (_apiKey.isEmpty) {
      throw Exception('Gemini API key not set. Add GEMINI_API_KEY to your .env or environment.');
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['candidates'][0]['content']['parts'][0]['text'];
      } else {
        throw Exception('Gemini API error: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback response for demo purposes
      return """
      **AI Analysis Complete**

      This is a simulated response. In the full version, Google Gemini API would provide detailed analysis.

      For prescription analysis, you would see:
      • Clean, digital version of your prescription
      • Simple explanations of each medicine
      • Dosage instructions in easy-to-understand terms
      • Important safety information

      For lab reports, you would see:
      • Summary of your test results
      • Highlighted abnormal values
      • Simple explanations of what each test means
      • Guidance on when to consult a doctor

      ⚠️ **Important**: Always consult with healthcare professionals for medical advice.
      """;
    }
  }
}