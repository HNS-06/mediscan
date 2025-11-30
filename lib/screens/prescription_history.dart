import 'package:flutter/material.dart';

class PrescriptionHistory extends StatelessWidget {
  const PrescriptionHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Prescription History')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text('Prescription history will be shown here. (Mock data for Phase 1)'),
        ),
      ),
    );
  }
}
