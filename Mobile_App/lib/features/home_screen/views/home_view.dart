import 'package:air_quality_iot_app/features/home_screen/view_models/home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final homeViewModel = context.watch<HomeViewModel>();
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final cardHeight = screenHeight * 0.22;
    final iconSize = screenWidth * 0.1;
    final fontSize = screenWidth * 0.04;

    return Scaffold(
      appBar: AppBar(title: Text("Air Quality IoT App")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: 20),
            
            // Sensor Data Grid
            Expanded(
              child: SingleChildScrollView(
                child: GridView.count(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisCount: screenWidth < 600 ? 2 : 4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: screenWidth < 400 ? 1.1 : 1.3,
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
            ),
            _buildAlerts(homeViewModel, fontSize),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildAlerts(HomeViewModel viewModel, double fontSize) {
    final alerts = <Widget>[];

    if (viewModel.humidity < 40) {
      alerts.add(_buildAlertItem("Low Humidity", Icons.warning, const Color.fromARGB(255, 255, 72, 0), fontSize));
    } else if (viewModel.humidity > 70) {
      alerts.add(_buildAlertItem("High Humidity", Icons.warning, Colors.blue, fontSize));
    }

    if (viewModel.temperature < 18) {
      alerts.add(_buildAlertItem("Low Temperature", Icons.thermostat, Colors.lightBlue, fontSize));
    } else if (viewModel.temperature > 28) {
      alerts.add(_buildAlertItem("High Temperature", Icons.thermostat, Colors.red, fontSize));
    }

    if (viewModel.tvoc > 220) {
      alerts.add(_buildAlertItem("High TVOC", Icons.air, Colors.purple, fontSize));
    }

    if (viewModel.eco2 > 800) {
      alerts.add(_buildAlertItem("High eCO2", Icons.cloud, Colors.deepOrange, fontSize));
    }

    if (alerts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "⚠️ Alerts ⚠️",
            style: TextStyle(
              fontSize: fontSize * 1.5,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          ...alerts,
        ],
      ),
    );
  }

  Widget _buildAlertItem(String message, IconData icon, Color color, double fontSize) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Card(
        elevation: 4,
        color: color.withOpacity(0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: ListTile(
          leading: Icon(icon, color: color, size: fontSize * 1.5),
          title: Text(
            message,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: fontSize * 1.2,
              color: color,
            ),
          ),
        ),
      ),
    );
  }

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
