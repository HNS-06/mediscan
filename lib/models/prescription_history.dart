class PrescriptionHistory {
  final String id;
  final String title;
  final DateTime scanDate;
  final String extractedText;
  final String analyzedText;
  final String imagePath;
  final bool isFavorite;

  PrescriptionHistory({
    required this.id,
    required this.title,
    required this.scanDate,
    required this.extractedText,
    required this.analyzedText,
    required this.imagePath,
    this.isFavorite = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'scanDate': scanDate.millisecondsSinceEpoch,
      'extractedText': extractedText,
      'analyzedText': analyzedText,
      'imagePath': imagePath,
      'isFavorite': isFavorite,
    };
  }

  factory PrescriptionHistory.fromMap(Map<String, dynamic> map) {
    return PrescriptionHistory(
      id: map['id'] ?? '',
      title: map['title'] ?? 'Untitled',
      scanDate: DateTime.fromMillisecondsSinceEpoch(map['scanDate'] ?? 0),
      extractedText: map['extractedText'] ?? '',
      analyzedText: map['analyzedText'] ?? '',
      imagePath: map['imagePath'] ?? '',
      isFavorite: map['isFavorite'] ?? false,
    );
  }
}