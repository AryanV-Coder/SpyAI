import 'package:flutter/material.dart';
import 'package:spyai/screens/tabs.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Call start-server endpoint when app builds (app starts)
    ApiService.startServer();

    return MaterialApp(home: TabsScreen(), debugShowCheckedModeBanner: false);
  }
}
