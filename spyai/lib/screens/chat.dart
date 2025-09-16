import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:convert';

// Chat Message Model
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() {
    return _ChatScreenState();
  }
}

class _ChatScreenState extends State<ChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Add welcome message
    _messages.add(ChatMessage(
      text: "🕵️ **Welcome to SpyAI Intelligence**\n\nI can help you search and analyze your recorded conversations. Ask me anything about your transcripts!",
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Add user message
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isLoading = true;
    });

    _textController.clear();
    _scrollToBottom();

    try {
      // Call the chat API
      final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1:8000';
      final response = await http.post(
        Uri.parse('$baseUrl/chat'),
        body: {'text': text},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _messages.add(ChatMessage(
            text: data['response'] ?? 'No response received',
            isUser: false,
            timestamp: DateTime.now(),
          ));
        });
      } else {
        setState(() {
          _messages.add(ChatMessage(
            text: "⚠️ **Error**: Unable to process your request. Please try again.",
            isUser: false,
            timestamp: DateTime.now(),
          ));
        });
      }
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(
          text: "❌ **Connection Error**: Unable to reach the server. Please check your connection.",
          isUser: false,
          timestamp: DateTime.now(),
        ));
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildMessage(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              radius: 20,
              backgroundColor: const Color.fromARGB(255, 123, 167, 217),
              child: const Icon(
                Icons.smart_toy_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: message.isUser 
                    ? const Color.fromARGB(255, 123, 167, 217)
                    : const Color.fromARGB(150, 10, 21, 37),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: message.isUser ? const Radius.circular(20) : const Radius.circular(5),
                  bottomRight: message.isUser ? const Radius.circular(5) : const Radius.circular(20),
                ),
                border: Border.all(
                  color: message.isUser 
                      ? Colors.transparent
                      : const Color.fromARGB(100, 123, 167, 217),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.isUser)
                    Text(
                      message.text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  else
                    MarkdownBody(
                      data: message.text,
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          height: 1.4,
                        ),
                        h1: const TextStyle(
                          color: Color.fromARGB(255, 123, 167, 217),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        h2: const TextStyle(
                          color: Color.fromARGB(255, 123, 167, 217),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        h3: const TextStyle(
                          color: Color.fromARGB(255, 123, 167, 217),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        strong: const TextStyle(
                          color: Color.fromARGB(255, 123, 167, 217),
                          fontWeight: FontWeight.bold,
                        ),
                        em: const TextStyle(
                          color: Colors.white70,
                          fontStyle: FontStyle.italic,
                        ),
                        code: const TextStyle(
                          color: Color.fromARGB(255, 255, 200, 100),
                          backgroundColor: Color.fromARGB(100, 0, 0, 0),
                          fontFamily: 'monospace',
                        ),
                        blockquote: const TextStyle(
                          color: Colors.white70,
                          fontStyle: FontStyle.italic,
                        ),
                        listBullet: const TextStyle(
                          color: Color.fromARGB(255, 123, 167, 217),
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: message.isUser ? Colors.white70 : Colors.white38,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 20,
              backgroundColor: const Color.fromARGB(255, 10, 21, 37),
              child: const Icon(
                Icons.person_outline,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    return "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 3, 28, 48),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 10, 21, 37),
        elevation: 0,
        title: const Row(
          children: [
            Icon(
              Icons.chat_bubble_outline,
              color: Color.fromARGB(255, 123, 167, 217),
              size: 24,
            ),
            SizedBox(width: 8),
            Text(
              'SpyAI Intelligence',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isLoading) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: const Color.fromARGB(255, 123, 167, 217),
                          child: const Icon(
                            Icons.smart_toy_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(150, 10, 21, 37),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color.fromARGB(100, 123, 167, 217),
                              width: 1,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color.fromARGB(255, 123, 167, 217),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Analyzing...',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return _buildMessage(_messages[index]);
              },
            ),
          ),
          // Input Area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 10, 21, 37),
              border: Border(
                top: BorderSide(
                  color: Color.fromARGB(100, 123, 167, 217),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(100, 3, 28, 48),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: const Color.fromARGB(100, 123, 167, 217),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      controller: _textController,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Ask about your recordings...',
                        hintStyle: TextStyle(
                          color: Colors.white38,
                          fontSize: 16,
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      onSubmitted: _sendMessage,
                      enabled: !_isLoading,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 123, 167, 217),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color.fromARGB(255, 123, 167, 217).withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: _isLoading ? null : () => _sendMessage(_textController.text),
                    icon: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
