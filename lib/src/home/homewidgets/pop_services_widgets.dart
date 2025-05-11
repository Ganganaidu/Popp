import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../models/pop_service_item.dart';

class PopServicesWidgets extends StatelessWidget {
  const PopServicesWidgets({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 20.0, left: 16.0, bottom: 8.0),
          child: Text(
            'Would you like to',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final popServices = items[index];
              final imageUrl = popServices.imageUrl;
              final hasValidUrl = imageUrl != null && imageUrl.isNotEmpty;

              return Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? 16.0 : 0.0,
                  right: 16.0,
                ),
                child: InkWell(
                  onTap: () {
                    // TODO Navigate or perform an action
                  },
                  splashColor: Colors.grey.shade300,
                  // Ripple color
                  borderRadius: BorderRadius.circular(12),
                  // Optional, to match your design
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Hero(
                        tag: 'service-image-${popServices.title}', // Unique tag
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: const BoxDecoration(
                            color: Colors.white70,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(12),
                          // adjust padding as needed
                          child: Image.asset(
                            popServices.assetImageUrl,
                            fit: BoxFit
                                .contain, // contain keeps it centered and scaled
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 100,
                        child: Text(
                          popServices.title ?? '',
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
