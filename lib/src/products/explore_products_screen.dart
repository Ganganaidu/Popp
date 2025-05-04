import 'package:flutter/material.dart';

class ExploreProductsScreen extends StatelessWidget {
  const ExploreProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mock categories data
    final List<Map<String, dynamic>> categories = [
      {'name': 'Premium Bikes', 'icon': Icons.motorcycle},
      {'name': 'Protection Gear', 'icon': Icons.security},
      {'name': 'Luggage', 'icon': Icons.backpack},
      {'name': 'Accessories', 'icon': Icons.build},
      {'name': 'Helmets', 'icon': Icons.sports_motorsports},
      {'name': 'Riding Jackets', 'icon': Icons.checkroom},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(12, 24, 12, 12), // top padding to avoid status bar
        child: GridView.builder(
          itemCount: categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final category = categories[index];
            return GestureDetector(
              onTap: () {
                // You can navigate to detailed page if needed
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Clicked on ${category['name']}')),
                );
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      category['icon'],
                      size: 50,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      category['name'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
