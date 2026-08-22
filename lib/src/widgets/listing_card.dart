import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:popp/src/utils/build_extensions.dart';
import 'package:popp/src/widgets/shimmer_image.dart';
import 'package:popp/src/theme/bikerverse_colors.dart';

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
    final isWeb = kIsWeb && context.isDesktop;
    if (isWeb) {
      return _buildWebCard(context);
    }
    return _buildMobileCard(context);
  }

  Widget _buildWebCard(BuildContext context) {
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
                  if ((showOptionsMenu || showSoldOptionOnly) &&
                      status?.toLowerCase() != 'sold')
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
                    maxLines: 2,
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

  Widget _buildMobileCard(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: BikerverseColors.card,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: BikerverseColors.outline),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.45),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
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
                  if ((showOptionsMenu || showSoldOptionOnly) &&
                      status?.toLowerCase() != 'sold')
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: BikerverseColors.textPrimary,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (price != null && price!.isNotEmpty) ...[
                    // const SizedBox(height: 10),
                    // Text(
                    //   'STARTING FROM',
                    //   style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    //         color: BikerverseColors.textMuted,
                    //         letterSpacing: 1.2,
                    //         fontWeight: FontWeight.w600,
                    //       ),
                    // ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            price!,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  color: BikerverseColors.priceGreen,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                        Container(
                          width: 30,
                          height: 30,
                          decoration: const BoxDecoration(
                            color: BikerverseColors.textPrimary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.black,
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
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        if (!showSoldOptionOnly && status?.toLowerCase() == 'pending')
          const PopupMenuItem<String>(
              value: 'edit',
              child: ListTile(
                  leading: Icon(Icons.edit_outlined), title: Text('Edit'))),
        if (!showSoldOptionOnly && status?.toLowerCase() == 'approved')
          const PopupMenuItem<String>(
              value: 'edit_approved',
              child: ListTile(
                  leading: Icon(Icons.edit_outlined, color: Colors.blue),
                  title: Text('Edit & Resubmit',
                      style: TextStyle(color: Colors.blue)))),
        const PopupMenuItem<String>(
            value: 'sold',
            child: ListTile(
                leading:
                    Icon(Icons.monetization_on_outlined, color: Colors.green),
                title: Text('Mark as Sold',
                    style: TextStyle(color: Colors.green)))),
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
      color: BikerverseColors.cardElevated,
      child: Icon(
        Icons.two_wheeler,
        color: Colors.white.withOpacity(0.35),
        size: 40,
      ),
    );
  }
}
