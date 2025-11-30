import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prescription_history.dart';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  static const String _recentScansKey = 'recent_scans';
  static const String _userNameKey = 'user_name';

  // Save prescription to history
  Future<bool> savePrescription(PrescriptionHistory prescription) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String> existingScans = prefs.getStringList(_recentScansKey) ?? [];

      // Decode existing JSON strings to maps
      final List<Map<String, dynamic>> scans = existingScans
          .map((s) => Map<String, dynamic>.from(jsonDecode(s)))
          .toList();

      // Insert new prescription at the beginning
      scans.insert(0, prescription.toMap());

      // Keep only last 50 scans
      if (scans.length > 50) scans.removeRange(50, scans.length);

      // Convert back to JSON strings
      final List<String> updatedScans = scans.map((map) => jsonEncode(map)).toList();

      return await prefs.setStringList(_recentScansKey, updatedScans);
    } catch (e) {
      print('Error saving prescription: $e');
      return false;
    }
  }

  // Get recent prescriptions
  Future<List<PrescriptionHistory>> getRecentPrescriptions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final List<String>? scansJson = prefs.getStringList(_recentScansKey);

      if (scansJson == null) return [];

      return scansJson.map((s) {
        try {
          final Map<String, dynamic> map = Map<String, dynamic>.from(jsonDecode(s));
          return PrescriptionHistory.fromMap(map);
        } catch (e) {
          print('Error parsing prescription: $e');
          return PrescriptionHistory(
            id: 'error',
            title: 'Error',
            scanDate: DateTime.now(),
            extractedText: '',
            analyzedText: '',
            imagePath: '',
          );
        }
      }).toList();
    } catch (e) {
      print('Error loading prescriptions: $e');
      return [];
    }
  }

  // Save user name
  Future<bool> saveUserName(String name) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_userNameKey, name);
    } catch (e) {
      print('Error saving user name: $e');
      return false;
    }
  }

  // Get user name
  Future<String> getUserName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userNameKey) ?? 'User';
    } catch (e) {
      print('Error loading user name: $e');
      return 'User';
    }
  }

  // Clear all data (for testing)
  Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      print('Error clearing data: $e');
    }
  }
}

// Using `dart:convert` for JSON encoding/decoding