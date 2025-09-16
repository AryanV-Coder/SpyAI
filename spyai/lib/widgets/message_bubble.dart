import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../models/chat_message.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../utils/time_helper.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: AppDimensions.messageSpacing, 
        horizontal: AppDimensions.paddingL
      ),
      child: Row(
        mainAxisAlignment: message.isUser 
            ? MainAxisAlignment.end 
            : MainAxisAlignment.start,
        children: [
          if (message.isUser) const Spacer(flex: 2),
          Flexible(
            flex: 7,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.messageBubblePadding,
                vertical: AppDimensions.paddingM,
              ),
              decoration: BoxDecoration(
                color: message.isUser 
                    ? AppColors.userMessageBackground
                    : AppColors.aiMessageBackground,
                borderRadius: BorderRadius.circular(AppDimensions.messageBubbleRadius),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.isUser)
                    Text(
                      message.text,
                      style: const TextStyle(
                        color: AppColors.primaryText,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    )
                  else
                    MarkdownBody(
                      data: message.text,
                      styleSheet: _getMarkdownStyleSheet(),
                    ),
                  const SizedBox(height: 6),
                  Align(
                    alignment: message.isUser 
                        ? Alignment.centerRight 
                        : Alignment.centerLeft,
                    child: Text(
                      TimeHelper.formatTime12Hour(message.timestamp),
                      style: const TextStyle(
                        color: AppColors.mutedText,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (!message.isUser) const Spacer(flex: 2),
        ],
      ),
    );
  }

  MarkdownStyleSheet _getMarkdownStyleSheet() {
    return MarkdownStyleSheet(
      p: const TextStyle(
        color: AppColors.primaryText,
        fontSize: 15,
        height: 1.4,
      ),
      h1: const TextStyle(
        color: AppColors.accent,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      h2: const TextStyle(
        color: AppColors.accent,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      h3: const TextStyle(
        color: AppColors.accent,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      strong: const TextStyle(
        color: AppColors.primaryText,
        fontWeight: FontWeight.w600,
      ),
      em: const TextStyle(
        color: AppColors.secondaryText,
        fontStyle: FontStyle.italic,
      ),
      code: const TextStyle(
        color: Color(0xFFFFC864),
        backgroundColor: Color.fromARGB(50, 0, 0, 0),
        fontFamily: 'monospace',
      ),
      blockquote: const TextStyle(
        color: AppColors.secondaryText,
        fontStyle: FontStyle.italic,
      ),
      listBullet: const TextStyle(
        color: AppColors.accent,
      ),
    );
  }
}