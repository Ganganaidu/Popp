import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'subscription_provider.dart';

class SubscribePageWidget extends StatelessWidget {
  final String userUid;

  const SubscribePageWidget({super.key, required this.userUid});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SubscriptionProvider>(context);
    final products = provider.products;

    return SafeArea(
      child: products.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(
                    "Subscribe",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(height: 32),
                Expanded(
                  child: ListView.separated(
                    itemCount: products.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product.description),
                            const SizedBox(height: 8),
                            Text(
                              'Price: ${product.price}  |  ${product.title}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: products.isEmpty
                              ? null
                              : () async {
                                  await provider.buy(products.first);
                                  await provider.updateUserSubscription(
                                      uid: userUid, isSubscribed: true);
                                  if (context.mounted) {
                                    Navigator.pop(context);
                                    Navigator.pushReplacementNamed(
                                        context, '/finalCongrats');
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text("Subscribe Now"),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            await provider.updateUserSubscription(
                                uid: userUid, isSubscribed: false);
                            if (context.mounted) {
                              Navigator.pop(context);
                              Navigator.pushReplacementNamed(
                                  context, '/finalCongrats');
                            }
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text("Skip"),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
