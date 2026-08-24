import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:popp/src/toolbar/common_app_bar.dart';
import 'package:intl/intl.dart';
import 'notification_service.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: CommonAppBar(
        title: 'Notifications',
        actions: [
          if (user != null)
            TextButton(
              onPressed: () => NotificationService.markAllAsRead(user.uid),
              child: const Text('Mark all read',
                  style: TextStyle(fontSize: 13)),
            ),
        ],
      ),
      body: user == null
          ? const Center(child: Text('Login to see your notifications'))
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: NotificationService.notificationsStream(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return _buildEmptyState(context);
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                      vertical: 8, horizontal: 12),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (context, i) {
                    final doc = docs[i];
                    final data = doc.data();
                    final bool isRead = data['isRead'] == true;
                    return _NotificationTile(
                      docId: doc.id,
                      uid: user.uid,
                      title: data['title'] ?? '',
                      body: data['body'] ?? '',
                      isRead: isRead,
                      type: data['type'] as String?,
                      createdAt: data['createdAt'] as Timestamp?,
                    );
                  },
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_outlined,
              size: 72, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
          const SizedBox(height: 16),
          Text('No notifications yet',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
          const SizedBox(height: 8),
          Text('You\'ll see listing updates and alerts here.',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5))),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final String docId;
  final String uid;
  final String title;
  final String body;
  final bool isRead;
  final String? type;
  final Timestamp? createdAt;

  const _NotificationTile({
    required this.docId,
    required this.uid,
    required this.title,
    required this.body,
    required this.isRead,
    this.type,
    this.createdAt,
  });

  IconData get _icon {
    switch (type) {
      case 'approved':
        return Icons.check_circle_outline;
      case 'sent_back':
        return Icons.undo_outlined;
      case 'rejected':
        return Icons.cancel_outlined;
      case 'chat':
        return Icons.chat_bubble_outline;
      case 'new_submission':
        return Icons.assignment_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _iconColor(BuildContext context) {
    switch (type) {
      case 'approved':
        return Colors.green;
      case 'sent_back':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      case 'chat':
        return Colors.blue;
      case 'new_submission':
        return Colors.purple;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  String _formatTime() {
    if (createdAt == null) return '';
    final dt = createdAt!.toDate();
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes == 0 ? 1 : diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else {
      return DateFormat('d MMM yyyy').format(dt);
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isRead
          ? null
          : () => NotificationService.markAsRead(uid, docId),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isRead
              ? Theme.of(context).cardColor
              : Theme.of(context).cardColor.withOpacity(1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isRead
                ? Theme.of(context).colorScheme.outlineVariant.withOpacity(0.5)
                : Theme.of(context).colorScheme.primary.withOpacity(0.35),
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Unread accent bar on the left
              if (!isRead)
                Container(
                  width: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      bottomLeft: Radius.circular(12),
                    ),
                  ),
                ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color:
                              _iconColor(context).withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(_icon,
                            color: _iconColor(context), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(
                                          fontWeight: isRead
                                              ? FontWeight.normal
                                              : FontWeight.bold,
                                          color: isRead
                                              ? Theme.of(context).colorScheme.onSurface.withOpacity(0.5)
                                              : null,
                                        ),
                                  ),
                                ),
                                Text(
                                  _formatTime(),
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              body,
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(isRead ? 0.5 : 0.8),
                                height: 1.4,
                              ),
                            ),
                            if (!isRead) ...[
                              const SizedBox(height: 6),
                              Text('Tap to mark as read',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4))),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
