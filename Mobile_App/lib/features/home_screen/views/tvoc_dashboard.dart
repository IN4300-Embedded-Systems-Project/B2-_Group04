import 'package:air_quality_iot_app/widgets/tvoc_gauge.dart';
import 'package:flutter/material.dart';

class TVOCDashboard extends StatelessWidget {
  final double tvocLevel;
  TVOCDashboard({required this.tvocLevel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('TVOC Dashboard')),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: TVOCGauge(tvocLevel: tvocLevel),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'TVOC Levels',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
