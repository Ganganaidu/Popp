import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ComingSoonScreen extends StatefulWidget {
  const ComingSoonScreen({super.key});

  @override
  State<ComingSoonScreen> createState() => _ComingSoonScreenState();
}

class _ComingSoonScreenState extends State<ComingSoonScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 3));
    // Start the animation and repeat it
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar removed as requested
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Lottie animation for visual appeal
              Lottie.network(
                'https://assets9.lottiefiles.com/packages/lf20_e3xphrjt.json',
                // Example Lottie URL (building animation)
                controller: _animationController,
                onLoaded: (composition) {
                  // Configure the animation controller to play the animation once loaded
                  _animationController
                    ..duration = composition.duration
                    ..repeat(); // Loop the animation
                },
                width: 250,
                // Adjust size as needed
                height: 250,
                fit: BoxFit.contain,
                // Optional: Fallback for when Lottie fails to load
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.construction,
                  size: 100,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.35),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Coming soon!',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'We’re building something awesome. Stay tuned!',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
