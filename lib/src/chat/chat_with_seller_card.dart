import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:popp/src/utils/build_extensions.dart';
import 'package:provider/provider.dart';

import '../api/api_url.dart';
import '../api/firebase/remote_config_service.dart';
import '../navigation/app_routes.dart';
import '../subscription/subscription_provider.dart';
import '../widgets/app_dialogs.dart';

class ChatWithSellerCard extends StatefulWidget {
  final String receiverUserName;
  final String receiverUserID;
  final String productId;
  final String productTitle;
  final bool isOwner;
  final bool isAdmin;
  final String? listingPhone;

  const ChatWithSellerCard(
      {super.key,
      required this.receiverUserName,
      required this.receiverUserID,
      required this.productId,
      required this.productTitle,
      this.isOwner = false,
      this.isAdmin = false,
      this.listingPhone});

  @override
  State<ChatWithSellerCard> createState() => _ChatWithSellerCardState();
}

class _ChatWithSellerCardState extends State<ChatWithSellerCard> {
  bool _showSubscription = false;

  @override
  void initState() {
    super.initState();
    _loadConfig();
  }

  void _loadConfig() async {
    final configService = await RemoteConfigService.getInstance();
    setState(() {
      _showSubscription = configService.isSubscriptionFeatureEnabled;
    });
  }

  void _openChatWithSeller(BuildContext context) async {
    context.pushUserChat(UserChatArgs(
      receiverUserName: widget.receiverUserName,
      receiverUserID: widget.receiverUserID,
      productId: widget.productId,
      productTitle: widget.productTitle,
    ));
  }

  Future<void> _showAdminContactSheet(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AdminContactSheet(
        userId: widget.receiverUserID,
        displayName: widget.receiverUserName,
        listingPhone: widget.listingPhone,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final isSubscribed = context.watch<SubscriptionProvider>().isSubscribed;
    final canChat = user != null && isSubscribed;
    final isSelfChat = widget.receiverUserID == user?.uid;
    final bool chatEnabled = !_showSubscription || (canChat && !isSelfChat);

    final card = Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: context.primaryColor,
              child: const Icon(Icons.person, color: Colors.white, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: GestureDetector(
                onTap: widget.isAdmin
                    ? () => _showAdminContactSheet(context)
                    : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.receiverUserName,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    if (isSelfChat)
                      const Text('Owner',
                          style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 16))
                    else
                      Text(
                        widget.isOwner ? 'Chat with Seller' : 'Chat with Provider',
                        style: const TextStyle(color: Colors.grey),
                      ),
                  ],
                ),
              ),
            ),
            if (!isSelfChat)
              ElevatedButton.icon(
                onPressed: chatEnabled
                    ? () => _openChatWithSeller(context)
                    : () {
                        String message;
                        if (user == null) {
                          message = 'Please login to use chat.';
                        } else {
                          message =
                              'Chat feature is available for subscribed users only. Please upgrade your plan to start chatting';
                        }
                        final confirmText =
                            user == null ? 'Login' : 'Subscribe';
                        AppDialogs.showConfirmationDialog(
                            context: context,
                            title: 'Chat Unavailable',
                            content: message,
                            confirmText: confirmText,
                            onConfirm: () {
                              if (user == null) {
                                context.goLogin();
                              } else {
                                context.pushMoreMenu();
                              }
                            });
                      },
                icon: const Icon(Icons.messenger_rounded),
                label: const Text('Chat'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: chatEnabled
                      ? Colors.green
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
              )
          ],
        ),
      ),
    );

    return card;
  }
}

class _AdminContactSheet extends StatefulWidget {
  final String userId;
  final String displayName;
  final String? listingPhone;

  const _AdminContactSheet({
    required this.userId,
    required this.displayName,
    this.listingPhone,
  });

  @override
  State<_AdminContactSheet> createState() => _AdminContactSheetState();
}

class _AdminContactSheetState extends State<_AdminContactSheet> {
  Map<String, dynamic>? _userData;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection(ApiUrl.userPath)
          .doc(widget.userId)
          .get();
      if (!mounted) return;
      setState(() {
        _userData = doc.data();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load user info.';
        _loading = false;
      });
    }
  }

  void _copyToClipboard(String value) {
    Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Copied to clipboard'), duration: Duration(seconds: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.admin_panel_settings, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              Text(
                'Seller Contact Info',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: cs.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Visible to admin only',
            style: TextStyle(color: Colors.orange, fontSize: 12),
          ),
          const SizedBox(height: 20),
          if (_loading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_error != null)
            Center(
              child: Text(_error!,
                  style: const TextStyle(color: Colors.red)),
            )
          else ...[
            _buildInfoRow(
              Icons.person_outline,
              'Name',
              _userData?['displayName'] ?? _userData?['username'] ?? widget.displayName,
            ),
            _buildInfoRow(
              Icons.email_outlined,
              'Email',
              _userData?['email'] ?? '—',
            ),
            _buildInfoRow(
              Icons.phone_outlined,
              'Phone',
              (widget.listingPhone ?? '').isNotEmpty ? widget.listingPhone! : '—',
            ),
            _buildInfoRow(
              Icons.location_city_outlined,
              'City / State',
              [_userData?['city'], _userData?['stateName']]
                  .where((v) => v != null && v.toString().isNotEmpty)
                  .join(', ')
                  .isNotEmpty
                  ? [_userData?['city'], _userData?['stateName']]
                      .where((v) => v != null && v.toString().isNotEmpty)
                      .join(', ')
                  : '—',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    final hasValue = value.isNotEmpty && value != '—';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 11,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 15),
                ),
              ],
            ),
          ),
          if (hasValue)
            GestureDetector(
              onTap: () => _copyToClipboard(value),
              child: Icon(Icons.copy_outlined,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                  size: 18),
            ),
        ],
      ),
    );
  }
}
