import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class TVOCGauge extends StatelessWidget {
  final double tvocLevel;

  TVOCGauge({required this.tvocLevel});

  @override
  Widget build(BuildContext context) {
    return SfRadialGauge(
      axes: <RadialAxis>[
        RadialAxis(
          minimum: 0,
          maximum: 500,
          ranges: [
            GaugeRange(startValue: 0, endValue: 150, color: Colors.green),
            GaugeRange(startValue: 150, endValue: 300, color: Colors.yellow),
            GaugeRange(startValue: 300, endValue: 500, color: Colors.red),
          ],
          pointers: <GaugePointer>[
            NeedlePointer(value: tvocLevel),
          ],
          annotations: <GaugeAnnotation>[
            GaugeAnnotation(
              widget: Text(
                '$tvocLevel ppb',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              angle: 90,
              positionFactor: 0.5,
            ),
          ],
        ),
      ],
    );
  }
}
