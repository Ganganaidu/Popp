import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_loger.dart';
import 'subscription_provider.dart';

class SubscribePageWidget extends StatefulWidget {
  final String userUid;
  final bool isFromSettings;

  const SubscribePageWidget({
    super.key,
    required this.userUid,
    required this.isFromSettings,
  });

  @override
  State<SubscribePageWidget> createState() => _SubscribePageWidgetState();
}

class _SubscribePageWidgetState extends State<SubscribePageWidget> {
  int? _selectedIndex;

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
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      final isFree = product.price.toLowerCase() == 'free' ||
                          product.price == '0' ||
                          product.price == '0.00' ||
                          product.price == '₹0' ||
                          product.price == '₹0.00';
                      final isSelected = _selectedIndex == index;
                      final bgColor = isSelected
                          ? Colors.blue.withOpacity(0.15)
                          : (isFree ? Colors.green[50] : null);
                      final priceWidget = Text(
                        product.price,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: isFree ? Colors.green[800] : null,
                        ),
                      );
                      final content = Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            priceWidget,
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    product.description,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedIndex = index;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          color: bgColor,
                          child: content,
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
                          onPressed: _selectedIndex == null
                              ? null
                              : () async {
                                  if (context.mounted) Navigator.pop(context);
                                  await provider.buy(products[_selectedIndex!]);
                                  await provider.updateUserSubscription(
                                      uid: widget.userUid, isSubscribed: true);
                                  if (!widget.isFromSettings &&
                                      context.mounted) {
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
                            if (context.mounted) Navigator.pop(context);
                            if (!widget.isFromSettings) {
                              await provider.updateUserSubscription(
                                  uid: widget.userUid, isSubscribed: false);
                              if (!context.mounted) return;
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
