import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';

class ApiService {
  static String get baseUrl => dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1:8000';

  // Chat API call
  static Future<Map<String, dynamic>> sendChatMessage(String text) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat'),
        body: {'text': text},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'response': data['response'] ?? 'No response received',
        };
      } else {
        return {
          'success': false,
          'error': 'Unable to process your request. Please try again.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Connection Error: Unable to reach the server. Please check your connection.',
      };
    }
  }

  // Recording upload API call
  static Future<Map<String, dynamic>> uploadAudioChunk(
    String filePath, 
    String recordingStartTime
  ) async {
    const int maxRetries = 3;
    
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final file = File(filePath);
        if (!file.existsSync()) {
          return {
            'success': false,
            'error': 'Audio file not found',
          };
        }

        final fileSize = await file.length();
        print('Uploading file: ${fileSize / (1024 * 1024)} MB');

        final request = http.MultipartRequest(
          'POST',
          Uri.parse('$baseUrl/recording-transcript'),
        );

        // Add headers for better compatibility
        request.headers['Connection'] = 'keep-alive';
        request.headers['User-Agent'] = 'SpyAI/1.0';

        request.fields['recording_start_time'] = recordingStartTime;
        request.files.add(await http.MultipartFile.fromPath('audio', filePath));

        // Set longer timeout for large files
        final response = await request.send().timeout(
          const Duration(minutes: 5),
          onTimeout: () {
            throw TimeoutException('Upload timeout after 5 minutes');
          },
        );

        if (response.statusCode == 200) {
          print('✅ Chunk uploaded successfully on attempt $attempt');
          return {
            'success': true,
            'message': 'Upload successful',
          };
        } else {
          print('❌ Upload failed with status: ${response.statusCode} on attempt $attempt');
          if (attempt == maxRetries) {
            return {
              'success': false,
              'error': 'Upload failed after $maxRetries attempts',
            };
          }
        }
      } catch (e) {
        print('❌ Upload error on attempt $attempt: $e');
        if (attempt == maxRetries) {
          return {
            'success': false,
            'error': 'Upload failed: $e',
          };
        }
        
        // Exponential backoff delay
        await Future.delayed(Duration(seconds: attempt * 2));
      }
    }

    return {
      'success': false,
      'error': 'Unexpected error occurred',
    };
  }

  // Server startup call
  static Future<void> startServer() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/start-server'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        print('✅ Server started successfully');
      } else {
        print('❌ Failed to start server: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error starting server: $e');
    }
  }
}