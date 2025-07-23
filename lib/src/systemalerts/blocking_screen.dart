import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'message_data.dart';

class BlockingScreen extends StatelessWidget {
  final SystemMessage systemMessage;

  const BlockingScreen({super.key, required this.systemMessage});

  Future<void> _saveMessageId() async {
    if (systemMessage.messageId != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('shown_message_${systemMessage.messageId}', 'true');
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isHighPriority = systemMessage.priority == MessagePriority.high;

    return PopScope(
      canPop: !isHighPriority,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    isHighPriority
                        ? Icons.lock_outline_rounded
                        : Icons.info_outline_rounded,
                    size: 80,
                    color: isHighPriority
                        ? Colors.redAccent
                        : Theme.of(context).primaryColor,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    isHighPriority ? 'Access Restricted' : 'Important Message',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    systemMessage.message,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  if (!isHighPriority)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                      ),
                      onPressed: () {
                        _saveMessageId();
                        // Allow dismissing low priority messages
                        if (systemMessage.priority == MessagePriority.low) {
                          Navigator.pushReplacementNamed(context, '/home');
                        }
                      },
                      child: const Text('Okay, I Understand'),
                    )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
