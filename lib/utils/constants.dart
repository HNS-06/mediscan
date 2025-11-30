class AppConstants {
  static const String appName = 'MediScan';
  static const String appTagline = 'AI-Powered Prescription & Lab Report Interpreter';
  
  // Colors
  static const int primaryColor = 0xFF1976D2;
  static const int secondaryColor = 0xFF42A5F5;
  static const int accentColor = 0xFF4CAF50;
  static const int warningColor = 0xFFFF9800;
  static const int dangerColor = 0xFFF44336;
  
  // Storage keys
  static const String recentScansKey = 'recent_scans';
  static const String userNameKey = 'user_name';
  static const String themeModeKey = 'theme_mode';
  
  // Mock data
  static const List<String> healthTips = [
    'Drink at least 8 glasses of water daily',
    'Get 7-8 hours of sleep every night',
    'Exercise for 30 minutes most days',
    'Eat a balanced diet with fruits and vegetables',
    'Take medications exactly as prescribed',
    'Wash hands frequently to prevent infections',
    'Manage stress through meditation or yoga',
    'Get regular health check-ups',
  ];
  
  static const List<Map<String, String>> quickActions = [
    {'title': 'Scan Rx', 'subtitle': 'New Prescription', 'icon': '📄'},
    {'title': 'Upload Lab', 'subtitle': 'Test Reports', 'icon': '🧪'},
    {'title': 'History', 'subtitle': 'Past Records', 'icon': '📊'},
    {'title': 'Reminders', 'subtitle': 'Medication Alerts', 'icon': '⏰'},
  ];
}