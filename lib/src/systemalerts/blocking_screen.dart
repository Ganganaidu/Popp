import 'package:flutter/material.dart';
import 'message_data.dart'; // Import the model from Step 2

class BlockingScreen extends StatelessWidget {
  final SystemMessage systemMessage;

  const BlockingScreen({super.key, required this.systemMessage});

  @override
  Widget build(BuildContext context) {
    final bool isHighPriority = systemMessage.priority == MessagePriority.high;

    return PopScope(
      // Prevent user from dismissing a high priority message
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
