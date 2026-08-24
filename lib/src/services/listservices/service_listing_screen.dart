import 'package:flutter/material.dart';
import 'package:popp/src/toolbar/common_app_bar.dart';
import 'package:popp/src/widgets/title_text.dart';
import 'package:provider/provider.dart';

import '../../filters/filter_bar.dart';
import '../../navigation/app_routes.dart';
import '../../utils/product_utils.dart';
import '../../widgets/web_constrained_box.dart';
import '../viewmodel/service_listing_viewmodel.dart';
import '../widgets/service_card.dart';

/// Service listing screen. Loading + filtering lives in
/// [ServiceListingViewModel] (provided at the route); this widget renders it.
class ServiceListingScreen extends StatefulWidget {
  final String category;
  final String? subCategory;

  const ServiceListingScreen(
      {super.key, required this.category, required this.subCategory});

  @override
  State<ServiceListingScreen> createState() => _ServiceListingScreenState();
}

class _ServiceListingScreenState extends State<ServiceListingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ServiceListingViewModel>().load(
            category: widget.category,
            subCategory: widget.subCategory,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ServiceListingViewModel>();
    final String appBarTitle =
        ProductUtils.getServiceAppBarTitle(widget.category);
    return Scaffold(
      appBar: CommonAppBar(
        titleWidget: TitleText(appBarTitle),
      ),
      body: _buildBody(context, vm),
    );
  }

  Widget _buildBody(BuildContext context, ServiceListingViewModel vm) {
    if (vm.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (vm.error != null) {
      return Center(child: Text('Error: ${vm.error}'));
    }
    if (vm.allServices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 100,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.35),
            ),
            const SizedBox(height: 20),
            Text(
              'No services found for this category yet.',
              style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Be the first to list a "${widget.category}" service!',
              style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final services = vm.filteredServices;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FilterBar(
          filters: const ['By State', 'By City', 'By Area'],
          dynamicStates: vm.availableStates,
          dynamicCities: vm.availableCities,
          dynamicAreas: vm.availableAreas,
          onFiltersChanged: vm.onFiltersChanged,
        ),
        if (services.isEmpty)
          Expanded(
            child: Center(
              child: Text(
                'No services match your filters.',
                style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
              ),
            ),
          ),
        if (services.isNotEmpty)
          Expanded(
            child: WebConstrainedBox(
              child: ListView.separated(
                padding: const EdgeInsets.all(16.0),
                itemCount: services.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final service = services[index];
                  return SizedBox(
                    height: 220,
                    child: ServiceCard(
                      service: service,
                      category: widget.category,
                      width: double.infinity,
                      onTap: () => context.pushServiceDetail(
                          service, widget.category),
                      isApproved: service['isApproved'] == true,
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}
