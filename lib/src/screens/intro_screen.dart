import 'package:flutter/material.dart';
import 'package:popp/src/systemalerts/auth_wrapper.dart';
import 'package:popp/src/utils/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IntroScreen extends StatelessWidget {
  const IntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pageController = PageController();
    // Force dark theme
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.green,
      ),
      child: Scaffold(
        appBar: AppBar(
          actions: [
            TextButton(
              onPressed: () => _onIntroComplete(context),
              child: const Text(
                'Skip',
                style:
                    TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
              ),
            ),
          ],
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Stack(
          children: [
            PageView(
              controller: pageController,
              children: [
                Stack(
                  children: [
                    const _IntroPage(
                      image: 'assets/app_icon_trans.png',
                      title: 'Welcome to ${Constants.appName}',
                      description:
                          'Your one-stop destination for all things motorcycles',
                    ),
                    Positioned(
                      right: 20,
                      top: 100,
                      bottom: 100,
                      child: RotatedBox(
                        quarterTurns: 1,
                        child: Text(
                          'BIKERVERSE',
                          style: TextStyle(
                            fontFamily: 'Orbitron',
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 8,
                            color: Colors.green.withOpacity(0.3),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const _IntroPage(
                  image: 'assets/intro_screen_01.png',
                  title: 'Your ultimate motorcycle Hub',
                  description:
                      'Everything you need, all in one place. From buying and selling bikes to finding the best riding gear and accessories.',
                ),
                _IntroPage(
                  image: 'assets/intro_screen_02.png',
                  title: 'Buy, List, find accessories and more',
                  description:
                      'Explore a marketplace for new and pre-owned bikes and essential riding gear. Your next adventure starts here.',
                  showGetStarted: true,
                  onGetStarted: () => _onIntroComplete(context),
                ),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 48,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  3,
                  (index) => AnimatedBuilder(
                    animation: pageController,
                    builder: (context, _) {
                      double page = pageController.hasClients
                          ? (pageController.page ?? 0)
                          : 0;
                      double opacity =
                          (1 - (page - index).abs()).clamp(0.3, 1.0);
                      double width = index == page.round() ? 24.0 : 8.0;

                      return Container(
                        width: width,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: Colors.green.withOpacity(opacity),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onIntroComplete(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenIntro', true);

    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const AuthWrapper(),
        ),
      );
    }
  }
}

class _IntroPage extends StatelessWidget {
  final String image;
  final String title;
  final String description;
  final bool showGetStarted;
  final VoidCallback? onGetStarted;

  const _IntroPage({
    required this.image,
    required this.title,
    required this.description,
    this.showGetStarted = false,
    this.onGetStarted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Image.asset(
              image,
              height: 200,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontFamily: 'Orbitron',
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          if (showGetStarted) ...[
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: onGetStarted,
              style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  backgroundColor: theme.primaryColor),
              child: const Text(
                'Get Started',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
          const Spacer(),
        ],
      ),
    );
  }
}
