import 'package:flutter/material.dart';
import 'package:spyai/screens/tabs.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // Function to call start-server endpoint in background
  Future<void> _startServer() async {
    try {
      final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1:8000';
      final response = await http.get(
        Uri.parse('$baseUrl/start-server'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        print('✅ Server started successfully');
      } else {
        print('❌ Server start failed: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error starting server: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Call start-server endpoint when app builds (app starts)
    _startServer();
    
    return MaterialApp(home: TabsScreen());
  }
}