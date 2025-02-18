import 'package:air_quality_iot_app/features/home_screen/views/home_view.dart';
import 'package:air_quality_iot_app/features/humidity_screen/views/humididty_dashboard.dart';
import 'package:air_quality_iot_app/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  static const String bottomnavbar = '/';
  static const String home = '/home';
  static const String humidity = '/humidity';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case bottomnavbar:
        return MaterialPageRoute(builder: (_) => BottomNavBar());
      case home:
        return MaterialPageRoute(builder: (_) => HomeView());
      case humidity:
        return MaterialPageRoute(builder: (_) => HumidityPage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(body: Center(child: Text('Page not found'))),
        );
    }
  }
}
