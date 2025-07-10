import 'package:flutter/material.dart';
import 'package:popp/src/widgets/shimmer_image.dart';

class ListingCard extends StatelessWidget {
  final String title;
  final String? imageUrl;
  final String? price;
  final bool showOptionsMenu;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onSold;
  final double? width;

  const ListingCard({
    super.key,
    this.width,
    required this.title,
    this.imageUrl,
    this.price,
    this.showOptionsMenu = false,
    this.onTap,
    this.onEdit,
    this.onSold,
  });

  @override
  Widget build(BuildContext context) {
    if (width == null) {
      return _buildCard(context);
    }
    return SizedBox(width: width, child: _buildCard(context));
  }

  Widget _buildCard(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Stack(
                children: [
                  SizedBox.expand(
                    child: imageUrl != null && imageUrl!.isNotEmpty
                        ? ShimmerImage(imageUrl: imageUrl!)
                        : _buildPlaceholderImage(),
                  ),
                  if (showOptionsMenu)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: _buildOptionsMenu(context),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                  if (price != null && price!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      price!,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsMenu(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'edit') {
          onEdit?.call();
        } else if (value == 'sold') {
          onSold?.call();
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
            value: 'edit',
            child: ListTile(
                leading: Icon(Icons.edit_outlined), title: Text('Edit'))),
        const PopupMenuItem<String>(
            value: 'sold',
            child: ListTile(
                leading:
                    Icon(Icons.monetization_on_outlined, color: Colors.orange),
                title: Text('Mark as Sold',
                    style: TextStyle(color: Colors.orange)))),
      ],
      icon: Container(
        decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4), shape: BoxShape.circle),
        child: const Icon(Icons.more_vert, color: Colors.white),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey.shade200,
      child: Icon(Icons.two_wheeler, color: Colors.grey.shade400, size: 40),
    );
  }
}
