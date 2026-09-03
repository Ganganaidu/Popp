import 'package:flutter/material.dart';
import 'package:popp/src/widgets/shimmer_image.dart';

class ListingCard extends StatelessWidget {
  final String title;
  final String? imageUrl;
  final String? price;
  final String? status;
  final bool showOptionsMenu;
  final bool showSoldOptionOnly;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onSold;
  final VoidCallback? onEditApproved;
  /// Admin-only: when provided, a red "Delete" entry is shown in the options
  /// menu regardless of the listing's status.
  final VoidCallback? onDelete;
  final double? width;

  const ListingCard({
    super.key,
    this.width,
    required this.title,
    this.imageUrl,
    this.price,
    this.status, // Default status is 'Pending'
    this.showOptionsMenu = false,
    this.showSoldOptionOnly = false,
    this.onTap,
    this.onEdit,
    this.onSold,
    this.onEditApproved,
    this.onDelete,
  });

  // Helper to determine banner color and icon based on status ---
  (Color, IconData?) _getStatusStyle(String status) {
    switch (status.toLowerCase()) {
      case 'sold':
        return (Colors.grey.shade700, Icons.money_off_outlined);
      case 'approved':
        return (Colors.green.shade600, Icons.check_circle_outline);
      case 'sent back':
        return (Colors.blue.shade600, Icons.undo_outlined);
      case 'rejected':
        return (Colors.red.shade700, Icons.cancel_outlined);
      case 'update pending':
        return (Colors.purple.shade600, Icons.sync_outlined);
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
    return _buildMobileCard(context);
  }

  Widget _buildMobileCard(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  SizedBox.expand(
                    child: imageUrl != null && imageUrl!.isNotEmpty
                        ? ShimmerImage(imageUrl: imageUrl!)
                        : _buildPlaceholderImage(),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.65),
                          ],
                          stops: const [0.5, 1.0],
                        ),
                      ),
                    ),
                  ),
                  if (status != null) _buildStatusBanner(),
                  if ((showOptionsMenu || showSoldOptionOnly || onDelete != null) &&
                      (onDelete != null || status?.toLowerCase() != 'sold'))
                    Positioned(
                      top: 4,
                      right: 4,
                      child: _buildOptionsMenu(context),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (price != null && price!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            price!,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ],
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
        } else if (value == 'edit_approved') {
          onEditApproved?.call();
        } else if (value == 'sold') {
          onSold?.call();
        } else if (value == 'delete') {
          onDelete?.call();
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        // Edit / Edit & Resubmit are owner actions ("My Listings" only). Admin
        // management tabs (showOptionsMenu == false) only get Delete.
        if (showOptionsMenu && status?.toLowerCase() == 'pending')
          const PopupMenuItem<String>(
              value: 'edit',
              child: ListTile(
                  leading: Icon(Icons.edit_outlined), title: Text('Edit'))),
        if (showOptionsMenu && status?.toLowerCase() == 'approved')
          PopupMenuItem<String>(
              value: 'edit_approved',
              child: ListTile(
                  leading: Icon(Icons.edit_outlined,
                      color: Theme.of(context).colorScheme.primary),
                  title: Text('Edit & Resubmit',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary)))),
        if ((showOptionsMenu || showSoldOptionOnly) &&
            status?.toLowerCase() != 'sold')
          PopupMenuItem<String>(
              value: 'sold',
              child: ListTile(
                  leading: Icon(Icons.monetization_on_outlined,
                      color: Theme.of(context).colorScheme.primary),
                  title: Text('Mark as Sold',
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary)))),
        if (onDelete != null)
          const PopupMenuItem<String>(
              value: 'delete',
              child: ListTile(
                  leading: Icon(Icons.delete_outline, color: Colors.red),
                  title: Text('Delete',
                      style: TextStyle(color: Colors.red)))),
      ],
      icon: Container(
        decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4), shape: BoxShape.circle),
        child: const Icon(Icons.more_vert, color: Colors.white),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Builder(builder: (context) {
      final cs = Theme.of(context).colorScheme;
      return Container(
        color: cs.surface,
        child: Icon(
          Icons.two_wheeler,
          color: cs.onSurface.withOpacity(0.25),
          size: 40,
        ),
      );
    });
  }
}
