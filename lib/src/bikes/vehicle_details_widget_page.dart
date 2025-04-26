import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class VehicleDetailsWidgetPage extends StatefulWidget {
  const VehicleDetailsWidgetPage({super.key});

  @override
  State<VehicleDetailsWidgetPage> createState() =>
      _VehicleDetailsWidgetPageState();
}

class _VehicleDetailsWidgetPageState extends State<VehicleDetailsWidgetPage> {
  final String sellerName = 'Rohan Sharma';
  final String phoneNumber = '+91 9876543210';
  final String location = 'Pune, Maharashtra';

  void _callSeller() async {
    final Uri url = Uri(scheme: 'tel', path: '+919876543210');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrls = [
      'https://images.unsplash.com/photo-1520342868574-5fa3804e551c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=6ff92caffcdd63681a35134a6770ed3b&auto=format&fit=crop&w=1951&q=80',
      'https://images.unsplash.com/photo-1520342868574-5fa3804e551c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=6ff92caffcdd63681a35134a6770ed3b&auto=format&fit=crop&w=1951&q=80',
      'https://images.unsplash.com/photo-1520342868574-5fa3804e551c?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=6ff92caffcdd63681a35134a6770ed3b&auto=format&fit=crop&w=1951&q=80',
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔹 Image Section
          Stack(
            children: [
              Image.network(
                imageUrls[0],
                width: double.infinity,
                height: 400,
                fit: BoxFit.cover,
              ),
              Positioned(
                bottom: 8,
                left: 12,
                child: Row(
                  children: imageUrls
                      .map((url) => Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.network(url,
                                  width: 100, height: 100, fit: BoxFit.cover),
                            ),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 6),
                const Text(
                  "Subaru Impreza WRX STI (2003)",
                  style: TextStyle(
                      fontSize: 25,
                      color: Colors.blue,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                const Text("1.2 E PETROL",
                    style: TextStyle(color: Colors.grey)),

                const SizedBox(height: 12),
                const Text(
                  "₹ 2,10,000",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 24),

                // 🔹 Seller Contact Card
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.blue,
                          child:
                              Icon(Icons.person, color: Colors.white, size: 30),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(sellerName,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              const SizedBox(height: 4),
                              Text(phoneNumber,
                                  style: const TextStyle(color: Colors.grey)),
                              const SizedBox(height: 4),
                              Text(location,
                                  style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _callSeller,
                          icon: const Icon(Icons.call),
                          label: const Text("Call"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        )
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
