import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

const List<Map<String, String>> _tips = [
  {'title': 'Stay Hydrated', 'body': 'Drink plenty of water throughout the day.'},
  {'title': 'Balanced Diet', 'body': 'Include fruits and vegetables in meals.'},
  {'title': 'Regular Checkups', 'body': 'Visit your doctor for routine tests.'},
];

class HealthTipsCarousel extends StatelessWidget {
  const HealthTipsCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      itemCount: _tips.length,
      itemBuilder: (context, index, realIdx) {
        final tip = _tips[index];
        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(tip['title']!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(tip['body']!, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        );
      },
      options: CarouselOptions(
        height: 120,
        enlargeCenterPage: true,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 4),
        viewportFraction: 0.85,
      ),
    );
  }
}
