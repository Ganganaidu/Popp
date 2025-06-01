import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SessionTimeoutHandler extends StatefulWidget {
  final Widget child;

  const SessionTimeoutHandler({super.key, required this.child});

  @override
  State<SessionTimeoutHandler> createState() => _SessionTimeoutHandlerState();
}

class _SessionTimeoutHandlerState extends State<SessionTimeoutHandler> {
  Timer? _inactivityTimer;
  static const sessionTimeout = Duration(minutes: 60);

  void _resetTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(sessionTimeout, _handleTimeout);
  }

  void _handleTimeout() {
    FirebaseAuth.instance.signOut();
    // Navigate to login screen or show session timeout dialog
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  void initState() {
    super.initState();
    _resetTimer();
  }

  @override
  void dispose() {
    _inactivityTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _resetTimer(),
      behavior: HitTestBehavior.translucent,
      child: widget.child,
    );
  }
}
