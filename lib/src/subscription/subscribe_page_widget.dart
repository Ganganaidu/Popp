import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'subscription_provider.dart';

class SubscribePageWidget extends StatelessWidget {
  const SubscribePageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SubscriptionProvider>(context);
    final product =
        provider.products.isNotEmpty ? provider.products.first : null;

    return Scaffold(
      appBar: AppBar(title: const Text("Subscribe")),
      body: product == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(product.title,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(product.description),
                  Text(product.price, style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => provider.buy(product),
                    child: const Text("Subscribe Now"),
                  ),
                ],
              ),
            ),
    );
  }
}
