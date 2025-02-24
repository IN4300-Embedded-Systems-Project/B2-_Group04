import 'package:air_quality_iot_app/features/home_screen/view_models/home_viewmodel.dart';
import 'package:air_quality_iot_app/routes/app_routes.dart';
import 'package:air_quality_iot_app/service/mqtt_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MQTTService().connect(); //
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeViewModel()),
        // Add other ViewModels here
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Air quality IoT app',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: AppRoutes.bottomnavbar,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
