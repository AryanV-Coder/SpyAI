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
        height: 1.5,
      ),
      h1: const TextStyle(
        color: AppColors.accent,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        height: 1.3,
      ),
      h2: const TextStyle(
        color: AppColors.accent,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      h3: const TextStyle(
        color: AppColors.accent,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.3,
      ),
      strong: const TextStyle(
        color: AppColors.primaryText,
        fontWeight: FontWeight.w700,
      ),
      em: const TextStyle(
        color: AppColors.accent,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w500,
      ),
      code: const TextStyle(
        color: Color(0xFFFFE066),
        backgroundColor: Color.fromARGB(80, 0, 0, 0),
        fontFamily: 'monospace',
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      codeblockDecoration: BoxDecoration(
        color: const Color.fromARGB(100, 0, 0, 0),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color.fromARGB(50, 123, 167, 217),
          width: 1,
        ),
      ),
      codeblockPadding: const EdgeInsets.all(12),
      blockquote: const TextStyle(
        color: AppColors.secondaryText,
        fontStyle: FontStyle.italic,
        fontSize: 14,
      ),
      blockquoteDecoration: BoxDecoration(
        color: const Color.fromARGB(30, 123, 167, 217),
        border: const Border(
          left: BorderSide(
            color: AppColors.accent,
            width: 3,
          ),
        ),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(4),
          bottomRight: Radius.circular(4),
        ),
      ),
      blockquotePadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      listBullet: const TextStyle(
        color: AppColors.accent,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      listIndent: 16,
      tableHead: const TextStyle(
        color: AppColors.accent,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      tableBody: const TextStyle(
        color: AppColors.primaryText,
        fontSize: 14,
      ),
      tableBorder: TableBorder.all(
        color: const Color.fromARGB(100, 123, 167, 217),
        width: 1,
      ),
      tableCellsPadding: const EdgeInsets.all(8),
      a: const TextStyle(
        color: AppColors.accent,
        decoration: TextDecoration.underline,
        decorationColor: AppColors.accent,
      ),
      del: const TextStyle(
        color: AppColors.secondaryText,
        decoration: TextDecoration.lineThrough,
        decorationColor: AppColors.secondaryText,
      ),
      checkbox: const TextStyle(
        color: AppColors.accent,
      ),
    );
  }
}