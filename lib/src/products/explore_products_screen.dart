import 'package:flutter/material.dart';

class ExploreProductsScreen extends StatelessWidget {
  const ExploreProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explore Products')),
      body: const Center(
        child: Text('All Products Page Here', style: TextStyle(fontSize: 24)),
      ),
    );
  }
}
