import 'package:air_quality_iot_app/features/humidity_screen/view_models/humidity_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'dart:math';


class HumidityPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Humidity Visualization (AHT21 Sensor)")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            HumidityIndicator(),
            SizedBox(height: 20),
            Expanded(child: HumidityChart()),
          ],
        ),
      ),
    );
  }
}

class HumidityIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HumidityProvider>(context);
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: provider.getHumidityColor(),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            "Current Humidity",
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
          Text(
            "${provider.currentHumidity.toStringAsFixed(1)}%",
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            provider.getHumidityStatus(),
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class HumidityChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<HumidityProvider>(context);
    return LineChart(
      LineChartData(
        minX: provider.humidityData.isNotEmpty ? provider.humidityData.first.x : 0,
        maxX: provider.humidityData.isNotEmpty ? provider.humidityData.last.x : 10,
        minY: 20,
        maxY: 90,
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 22)),
        ),
        borderData: FlBorderData(show: true, border: Border.all(color: Colors.black)),
        lineBarsData: [
          LineChartBarData(
            spots: provider.humidityData,
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            isStrokeCapRound: true,
            belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.3)),
          ),
        ],
      ),
    );
  }
}