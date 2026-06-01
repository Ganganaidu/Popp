import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../repository/ad_carousel_viewmodel.dart';
import '../model/ad_banner.dart';
import 'ads_submission_screen.dart';
import '../../widgets/app_network_image.dart';

class AdListPage extends StatefulWidget {
  const AdListPage({super.key});

  @override
  State<AdListPage> createState() => _AdListPageState();
}

class _AdListPageState extends State<AdListPage> {
  @override
  void initState() {
    super.initState();
    // Load ads after first frame using the provided view model from AppProviders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = Provider.of<AdCarouselViewModel>(context, listen: false);
      vm.loadAds(); // load all ads by default
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AdCarouselViewModel>(context);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => vm.loadAds(),
        child: vm.isLoading && vm.ads.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  children: [
                    if (vm.error != null)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                vm.error ?? '',
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                            TextButton(
                              onPressed: () => vm.loadAds(),
                              child: const Text('Retry'),
                            )
                          ],
                        ),
                      ),
                    if (vm.ads.isEmpty)
                      Expanded(
                        child: Center(
                          child: Text(
                              vm.isLoading ? 'Loading...' : 'No ads found'),
                        ),
                      )
                    else
                      Expanded(
                        child: ListView.separated(
                          itemCount: vm.ads.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final ad = vm.ads[index];
                            return ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              leading: _buildLeading(ad),
                              title: Text(ad.title.isNotEmpty
                                  ? ad.title
                                  : '(No title)'),
                              subtitle: Text(ad.subtitle.isNotEmpty
                                  ? ad.subtitle
                                  : ad.highlight),
                              trailing: vm.isLoading
                                  ? const SizedBox(
                                      width: 36,
                                      height: 36,
                                      child: Center(
                                          child: SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 2))),
                                    )
                                  : Switch(
                                      value: ad.isActive,
                                      onChanged: (_) => vm.toggleAdStatus(ad),
                                      // Off state colors (gray). On state uses theme defaults.
                                      inactiveThumbColor: Colors.grey,
                                      inactiveTrackColor: Colors.grey.shade400,
                                    ),
                              onTap: () {
                                // Optionally open details or edit screen in future
                              },
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
      ),
      // Bottom sticky button to navigate to AdsSubmissionScreen
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(12.0),
        child: SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Create / Submit Ad'),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AdsSubmissionScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeading(AdBanner ad) {
    // Use asset when imageUrl is empty or null-equivalent
    if (ad.imageUrl.trim().isEmpty) {
      return SizedBox(
        width: 64,
        height: 64,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.asset(
            'assets/ads_default_image.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                const Center(child: Icon(Icons.broken_image)),
          ),
        ),
      );
    }

    return SizedBox(
      width: 64,
      height: 64,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: AppNetworkImage(
          imageUrl: ad.imageUrl,
          fit: BoxFit.cover,
          errorWidget: const Center(child: Icon(Icons.broken_image)),
          placeholder: const Center(
              child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2))),
        ),
      ),
    );
  }
}
