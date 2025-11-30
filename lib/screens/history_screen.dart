import 'package:flutter/material.dart';
import '../widgets/recent_activity_item.dart';
import '../utils/helpers.dart';
import '../services/local_storage_service.dart';
import '../models/prescription_history.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final LocalStorageService _storageService = LocalStorageService();
  late Future<List<PrescriptionHistory>> _historyFuture;
  List<PrescriptionHistory> _allHistory = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    _historyFuture = _storageService.getRecentPrescriptions().then((history) {
      _allHistory = history;
      return history;
    });
  }

  List<PrescriptionHistory> get _filteredHistory {
    if (_searchQuery.isEmpty) return _allHistory;
    
    return _allHistory.where((prescription) {
      return prescription.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             prescription.extractedText.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _refreshHistory() {
    setState(() {
      _loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan History'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshHistory,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search prescriptions...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          // History List
          Expanded(
            child: FutureBuilder<List<PrescriptionHistory>>(
              future: _historyFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          'Error loading history',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _refreshHistory,
                          child: const Text('Try Again'),
                        ),
                      ],
                    ),
                  );
                }

                final filteredHistory = _filteredHistory;

                if (filteredHistory.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.history, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty 
                              ? 'No scan history yet' 
                              : 'No matching prescriptions found',
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        if (_searchQuery.isEmpty)
                          Text(
                            'Start by scanning your first prescription',
                            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                          ),
                        if (_searchQuery.isNotEmpty)
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                            child: const Text('Clear Search'),
                          ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    _refreshHistory();
                    await Future.delayed(const Duration(milliseconds: 500));
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredHistory.length,
                    itemBuilder: (context, index) {
                      final prescription = filteredHistory[index];
                      return RecentActivityItem(
                        prescription: prescription,
                        onTap: () {
                          _showPrescriptionDetails(context, prescription);
                        },
                        onFavorite: () {
                          _toggleFavorite(prescription);
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showPrescriptionDetails(BuildContext context, PrescriptionHistory prescription) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  prescription.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Scanned on: ${Helpers.formatDate(prescription.scanDate)} at ${Helpers.formatTime(prescription.scanDate)}',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            const Text(
              'Extracted Text:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(prescription.extractedText),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _toggleFavorite(PrescriptionHistory prescription) {
    // In a real app, this would update the storage
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          prescription.isFavorite 
              ? 'Removed from favorites' 
              : 'Added to favorites',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}