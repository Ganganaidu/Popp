import 'package:flutter/material.dart';

// Chat bubble widget - assuming this is a separate widget in your project
// Included for completeness, but you can use your existing ChatBubble.
class ChatBubble extends StatelessWidget {
  final String message;

  final bool isCurrentUser;

  const ChatBubble(
      {super.key, required this.message, this.isCurrentUser = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isCurrentUser
            ? Colors.orange[700]
            : Colors.grey[300], // Different colors
      ),
      child: Text(
        message,
        style: TextStyle(
          fontSize: 16,
          color: isCurrentUser ? Colors.white : Colors.black87,
        ),
      ),
    );
  }
}
