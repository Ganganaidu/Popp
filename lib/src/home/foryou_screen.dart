import 'package:flutter/material.dart';

import 'package:poppflutter/src/homepagewidgets/carousel_widget.dart';
import 'package:poppflutter/src/homepagewidgets/for_you_main_list_widget.dart';
import 'package:poppflutter/src/disclaimers/app_disclaimers.dart';

class ForYouScreen extends StatefulWidget {
  const ForYouScreen({super.key});

  @override
  State<ForYouScreen> createState() => _ForYouScreen();
}

class _ForYouScreen extends State<ForYouScreen> {

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SingleChildScrollView(
        // Wrap the entire content with SingleChildScrollView
        child: Column(
          children: [
            SizedBox(height: 10),
            CarouselWidget(),
            SizedBox(height: 30),
            ForYouListViewWidget(),
            SizedBox(height: 50),
            Disclaimers(),
          ],
        ),
      ),
    );
  }
}

