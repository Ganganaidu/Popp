import 'package:flutter/material.dart';
import 'package:popp/src/utils/build_extensions.dart';
import 'package:popp/src/widgets/shimmer_image.dart';

class ListingCard extends StatelessWidget {
  final String title;
  final String? imageUrl;
  final String? price;
  final String? status;
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
    this.status, // Default status is 'Pending'
    this.showOptionsMenu = false,
    this.onTap,
    this.onEdit,
    this.onSold,
  });

  // Helper to determine banner color and icon based on status ---
  (Color, IconData?) _getStatusStyle(String status) {
    switch (status.toLowerCase()) {
      case 'sold':
        return (Colors.grey.shade700, Icons.money_off_outlined);
      case 'approved':
        return (Colors.green.shade600, Icons.check_circle_outline);
      default: // 'Pending' or any other status
        return (Colors.orange.shade700, Icons.hourglass_top_outlined);
    }
  }

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
                  if (showOptionsMenu &&
                      (status?.toLowerCase() != 'pending' &&
                          status?.toLowerCase() != 'sold'))
                    Positioned(
                      top: 4,
                      right: 4,
                      child: _buildOptionsMenu(context),
                    ),
                  if (status != null) _buildStatusBanner(),
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
                            color: context.primaryColor,
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

  // --- NEW: Widget to build the status banner ---
  Widget _buildStatusBanner() {
    final (color, icon) = _getStatusStyle(status!);
    return Positioned(
      top: 0,
      left: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12),
            bottomRight: Radius.circular(12),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(2, 2),
            )
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 14),
            const SizedBox(width: 4),
            Text(
              status!,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
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
        if (status?.toLowerCase() == 'pending')
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
