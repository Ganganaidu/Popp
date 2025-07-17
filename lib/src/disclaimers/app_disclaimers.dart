import 'package:flutter/material.dart';
import 'package:popp/src/utils/app_constants.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/api_url.dart';

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
          const Text(
            'Important Disclaimers',
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 16),

          // Description with Hyperlink
          const Text(
            'Please read the following disclaimers carefully. By using our app, you agree to our ',
            style: TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: () => launchUrl(Uri.parse(ApiUrl.privacyLink)),
            child: const Text(
              'Terms of Use & Privacy Policy',
              style: TextStyle(
                  color: Colors.white, decoration: TextDecoration.underline),
            ),
          ),
          const SizedBox(height: 16),
          // Phone Number and Email
          const Text('Contact Us:', style: TextStyle(color: Colors.white)),
          InkWell(
            onTap: () => launchUrl(Uri(scheme: 'tel', path: Constants.contactNumber)),
            child: const Row(
              children: [
                Icon(Icons.call_end_outlined,
                    color: Colors.orangeAccent, size: 32),
                SizedBox(width: 16),
                Text('+91 995 5995 8899',
                    style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          InkWell(
            onTap: () => launchUrl(Uri(
                scheme: 'mailto', path: Constants.contactEmail)),
            child: const Row(
              children: [
                Icon(Icons.email_outlined,
                    color: Colors.orangeAccent, size: 32),
                SizedBox(width: 16),
                Text('support@poppapp.in',
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
