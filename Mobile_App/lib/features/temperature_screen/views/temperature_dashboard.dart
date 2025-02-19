import 'package:air_quality_iot_app/features/temperature_screen/view_models/temperature_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'dart:async';

class TemperaturePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Temperature Visualization (AHT21 Sensor)")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TemperatureIndicator(),
            SizedBox(height: 20),
            Expanded(child: TemperatureChart()),
          ],
        ),
      ),
    );
  }
}

class TemperatureIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TemperatureProvider>(context);
    
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: provider.getTemperatureColor(),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            "Current Temperature",
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
          Text(
            "${provider.currentTemperature.toStringAsFixed(1)}°C",
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            provider.getTemperatureStatus(),
            style: TextStyle(fontSize: 20, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

class TemperatureChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TemperatureProvider>(context);
    
    return LineChart(
      LineChartData(
        minX: provider.temperatureData.isNotEmpty ? provider.temperatureData.first.x : 0,
        maxX: provider.temperatureData.isNotEmpty ? provider.temperatureData.last.x : 10,
        minY: -10,
        maxY: 50,
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 30)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 22)),
        ),
        borderData: FlBorderData(show: true, border: Border.all(color: Colors.black)),
        lineBarsData: [
          LineChartBarData(
            spots: provider.temperatureData,
            isCurved: true,
            color: provider.getChartLineColor(),
            barWidth: 3,
            isStrokeCapRound: true,
            belowBarData: BarAreaData(show: true, color: provider.getChartLineColor().withOpacity(0.3)),
          ),
        ],
      ),
    );
  }
}