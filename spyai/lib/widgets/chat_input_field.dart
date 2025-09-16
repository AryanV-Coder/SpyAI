import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';

class ChatInputField extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final Function(String) onSendMessage;
  final String hintText;

  const ChatInputField({
    super.key,
    required this.controller,
    required this.isLoading,
    required this.onSendMessage,
    this.hintText = 'Ask about your recordings...',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.paddingXL),
      color: AppColors.primaryBackground,
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
                border: Border.all(
                  color: AppColors.inputBorder,
                  width: 1,
                ),
              ),
              child: TextField(
                controller: controller,
                style: const TextStyle(
                  color: AppColors.primaryText,
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: const TextStyle(
                    color: AppColors.mutedText,
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.inputPaddingH,
                    vertical: AppDimensions.inputPaddingV,
                  ),
                ),
                onSubmitted: onSendMessage,
                enabled: !isLoading,
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.paddingM),
          _buildSendButton(),
        ],
      ),
    );
  }

  Widget _buildSendButton() {
    return Container(
      width: AppDimensions.inputHeight,
      height: AppDimensions.inputHeight,
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCircular),
      ),
      child: IconButton(
        onPressed: isLoading ? null : () => onSendMessage(controller.text),
        icon: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryText),
                ),
              )
            : const Icon(
                Icons.arrow_upward_rounded,
                color: AppColors.primaryText,
                size: 22,
              ),
      ),
    );
  }
}