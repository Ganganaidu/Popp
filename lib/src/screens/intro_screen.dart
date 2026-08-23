import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:popp/src/toolbar/common_app_bar.dart';
import 'package:popp/src/utils/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'intro_page.dart';

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
        appBar: CommonAppBar(
          showBackButton: false,
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
        ),
        body: Stack(
          children: [
            PageView(
              controller: pageController,
              children: [
                Stack(
                  children: [
                    const IntroPage(
                      image: 'assets/app_icon_trans.png',
                      title: 'Welcome to ${Constants.appName}',
                      description:
                          'Your one-stop destination for INDIA\'s First Unified Motorcycle Market Place',
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
                const IntroPage(
                  image: 'assets/intro_screen_01.png',
                  title: 'Your ultimate motorcycle Hub',
                  description:
                      'Everything you need is all in one place. From buying and selling bikes to finding the best riding gear and accessories.',
                ),
                IntroPage(
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
      // Hand back to the router; its redirect sends the user to /home when
      // authenticated, or /login otherwise.
      context.go('/home');
    }
  }
}
