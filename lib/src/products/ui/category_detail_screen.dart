import 'package:flutter/material.dart';
import 'package:popp/src/api/currency_service.dart';
import 'package:popp/src/toolbar/common_app_bar.dart';
import 'package:provider/provider.dart';

import '../../filters/filter_bar.dart';
import '../../navigation/app_routes.dart';
import '../../utils/product_utils.dart';
import '../../widgets/listing_card.dart';
import '../../widgets/title_text.dart';
import '../../widgets/web_constrained_box.dart';
import '../viewmodel/category_products_viewmodel.dart';

/// Category listing screen. Product loading + filtering lives in
/// [CategoryProductsViewModel] (provided at the route); this widget renders the
/// resulting state.
class CategoryDetailScreen extends StatefulWidget {
  final CategoryDetailArgs args;

  const CategoryDetailScreen({super.key, required this.args});

  @override
  State<CategoryDetailScreen> createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProductsViewModel>().load(
            categoryName: widget.args.categoryName,
            subCategory: widget.args.subCategory,
            initialProducts: widget.args.products,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CategoryProductsViewModel>();
    final String countryCode = Localizations.localeOf(context).countryCode ?? 'US';
    return Scaffold(
      appBar: CommonAppBar(
        titleWidget: TitleText(widget.args.categoryName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : vm.error != null
              ? Center(
                  child: Text(vm.error!,
                      style: const TextStyle(color: Colors.red)))
              : WebConstrainedBox(
                  child: Column(
                    children: [
                      FilterBar(
                        filters: widget.args.filters,
                        activeFilterCounts: const {},
                        onFiltersChanged: vm.onFiltersChanged,
                        products: vm.sourceProducts,
                      ),
                      Expanded(
                        child: vm.filteredProducts.isEmpty
                            ? _buildEmptyProductsView(context)
                            : Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: GridView.builder(
                                  itemCount: vm.filteredProducts.length,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount:
                                        MediaQuery.of(context).size.width > 800
                                            ? 4
                                            : 2,
                                    childAspectRatio: 0.65,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                  ),
                                  itemBuilder: (context, index) {
                                    final product = vm.filteredProducts[index];
                                    return ListingCard(
                                        title: ProductUtils
                                            .getBrandAndModelName(product),
                                        imageUrl: ProductUtils
                                            .extractAllImageUrls(product),
                                        price: CurrencyService.getProductPrice(
                                            product['expectedPrice'],
                                            countryCode),
                                        width: double.infinity,
                                        showOptionsMenu: false,
                                        onTap: () => context
                                            .pushProductDetail(product));
                                  },
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildEmptyProductsView(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.35)),
          const SizedBox(height: 24),
          Text(
            'No products available',
            style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or check back later.',
            style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }
}
