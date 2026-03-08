import 'package:flutter/foundation.dart';

class ActiveChatProvider {
  // Static variable to track the globally open chat room ID.
  // Using a ValueNotifier allows Reactivity anywhere in the app without context if needed.
  static final ValueNotifier<String?> activeChatRoomId = ValueNotifier(null);

  // Helper function to set the active chat room
  static void setActiveChat(String chatRoomId) {
    activeChatRoomId.value = chatRoomId;
  }

  // Helper function to clear the active chat room (e.g., when leaving the chat screen)
  static void clearActiveChat() {
    activeChatRoomId.value = null;
  }
}
