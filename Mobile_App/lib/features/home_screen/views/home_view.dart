import 'package:air_quality_iot_app/features/home_screen/view_models/home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final homeViewModel = context.watch<HomeViewModel>();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final cardHeight =
        screenHeight * 0.22; // Adjusted height for responsiveness
    final iconSize = screenWidth * 0.1; // Adjust icon size dynamically
    final fontSize = screenWidth * 0.04; // Adjust text size dynamically

    return Scaffold(
      appBar: AppBar(title: Text("Air Quality IoT App")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "",
              style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),

            // Sensor Data Grid
            Expanded(
              child: GridView.count(
                crossAxisCount: screenWidth < 600
                    ? 2
                    : 4, // 2 columns for small screens, 4 for large
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.3,
                children: [
                  _sensorCard(
                    title: "Humidity",
                    value: "${homeViewModel.humidity.toStringAsFixed(1)}%",
                    icon: Icons.water_drop,
                    color: Colors.blue,
                    cardHeight: cardHeight,
                    iconSize: iconSize,
                    fontSize: fontSize,
                  ),
                  _sensorCard(
                    title: "Temperature",
                    value: "${homeViewModel.temperature.toStringAsFixed(1)}°C",
                    icon: Icons.thermostat,
                    color: Colors.orange,
                    cardHeight: cardHeight,
                    iconSize: iconSize,
                    fontSize: fontSize,
                  ),
                  _sensorCard(
                    title: "TVOC",
                    value: "${homeViewModel.tvoc.toStringAsFixed(1)} ppb",
                    icon: Icons.air,
                    color: Colors.green,
                    cardHeight: cardHeight,
                    iconSize: iconSize,
                    fontSize: fontSize,
                  ),
                  _sensorCard(
                    title: "CO₂",
                    value: "${homeViewModel.eco2.toStringAsFixed(1)} ppm",
                    icon: Icons.cloud,
                    color: Colors.red,
                    cardHeight: cardHeight,
                    iconSize: iconSize,
                    fontSize: fontSize,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget for each sensor card
  Widget _sensorCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required double cardHeight,
    required double iconSize,
    required double fontSize,
  }) {
    return Container(
      height: cardHeight,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: iconSize, color: color),
              SizedBox(height: 8),
              Text(title,
                  style: TextStyle(
                      fontSize: fontSize, fontWeight: FontWeight.bold)),
              Text(value,
                  style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
