import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Disclaimers extends StatelessWidget {
  const Disclaimers({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueGrey,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          // const Text(
          //   'Important Disclaimers',
          //   style: TextStyle(
          //       fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          // ),
          // const SizedBox(height: 16),
          //
          // // Description with Hyperlink
          // const Text(
          //   'Please read the following disclaimers carefully. By using our app, you agree to our ',
          //   style: TextStyle(color: Colors.white),
          // ),
          // const SizedBox(height: 16),
          // InkWell(
          //   onTap: () => launchUrl(Uri.parse('https://www.example.com/terms')),
          //   child: const Text(
          //     'Terms of Service',
          //     style: TextStyle(
          //         color: Colors.white, decoration: TextDecoration.underline),
          //   ),
          // ),
          // const SizedBox(height: 10),
          // InkWell(
          //   onTap: () =>
          //       launchUrl(Uri.parse('https://www.example.com/privacy')),
          //   child: const Text(
          //     'Privacy Policy',
          //     style: TextStyle(
          //         color: Colors.white, decoration: TextDecoration.underline),
          //   ),
          // ),
          // const SizedBox(height: 16),

          // Additional Disclaimer Sections (Repeat as needed)
          const Text(
            'Disclaimer for Content:',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          const Text(
              'The content provided in this app is for informational purposes only and should not be considered professional advice.',
              style: TextStyle(color: Colors.white)),
          const SizedBox(height: 20),
          // Phone Number and Email
          const Text('Contact Us:', style: TextStyle(color: Colors.white)),
          InkWell(
            onTap: () => launchUrl(Uri(scheme: 'tel', path: '+15551234567')),
            child: const Row(
              children: [
                Icon(Icons.call_end_outlined,
                    color: Colors.orangeAccent, size: 32),
                SizedBox(width: 16),
                Text('+1 (555) 123-4567',
                    style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          InkWell(
            onTap: () =>
                launchUrl(Uri(scheme: 'mailto', path: 'support@example.com')),
            child: const Row(
              children: [
                Icon(Icons.email_outlined,
                    color: Colors.orangeAccent, size: 32),
                SizedBox(width: 16),
                Text('support@example.com',
                    style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
