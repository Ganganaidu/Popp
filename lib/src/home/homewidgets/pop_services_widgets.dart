import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:poppflutter/src/services/accessories/sell_your_accessories.dart';
import '../../models/pop_service_item.dart';
import '../../services/bikes/sell_your_bike.dart';
import '../../widgets/app_dialogs.dart';

class PopServicesWidgets extends StatelessWidget {
  const PopServicesWidgets({super.key});

  void _handleAction(BuildContext context, PopServiceAction action) {
    final user = FirebaseAuth.instance.currentUser;
    switch (action) {
      case PopServiceAction.sellBike:
        if (user == null) {
          AppDialogs.showUserLoginDialog(context, () {
            Navigator.pushReplacementNamed(context, '/login');
          }, "sell your bike");
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SellYourBike()),
        );
        break;
      case PopServiceAction.sellAccessory:
        if (user == null) {
          AppDialogs.showUserLoginDialog(context, () {
            Navigator.pushReplacementNamed(context, '/login');
          }, "sell your bike");
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SellYourAccessories()),
        );
        break;
        case PopServiceAction.bookService:
      case PopServiceAction.comingSoon:
      AppDialogs.showComingSoonDialog(context, () {});
      case PopServiceAction.bookTrackTraining:
        AppDialogs.showComingSoonDialog(context, () {});
      case PopServiceAction.findBikeRentals:
        AppDialogs.showComingSoonDialog(context, () {});
      case PopServiceAction.listYourServices:
        AppDialogs.showComingSoonDialog(context, () {});
      case PopServiceAction.premiumBikeInspection:
        AppDialogs.showComingSoonDialog(context, () {});
    }
  }

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

              return Padding(
                padding: EdgeInsets.only(
                  left: index == 0 ? 16.0 : 0.0,
                  right: 16.0,
                ),
                child: InkWell(
                  onTap: () => _handleAction(context, popServices.action),
                  splashColor: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Hero(
                        tag: 'service-image-${popServices.title}',
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: const BoxDecoration(
                            color: Colors.white70,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Image.asset(
                            popServices.assetImageUrl,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: 100,
                        child: Text(
                          popServices.title,
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
