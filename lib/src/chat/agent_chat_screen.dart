import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat_service.dart';

class AgentChatScreen extends StatelessWidget {
  const AgentChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ChatService chatService = ChatService();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Agent Chat Dashboard'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: chatService.getChatRooms(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final chatRooms = snapshot.data!.docs;
          return ListView.builder(
            itemCount: chatRooms.length,
            itemBuilder: (context, index) {
              final chatRoom = chatRooms[index];
              final customerId = chatRoom.id;
              return ListTile(
                title: Text('Chat with $customerId'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (_) => AgentChatDetailScreen(customerId: customerId),
                  ));
                },
              );
            },
          );
        },
      ),
    );
  }
}

class AgentChatDetailScreen extends StatefulWidget {
  final String customerId;

  const AgentChatDetailScreen({super.key, required this.customerId});

  @override
  State<AgentChatDetailScreen> createState() => _AgentChatDetailScreenState();
}

class _AgentChatDetailScreenState extends State<AgentChatDetailScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _controller = TextEditingController();

  final String agentId = 'agent1'; // dummy agentId

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    _chatService.sendCustomerMessage(widget.customerId, _controller.text.trim(), agentId);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat with ${widget.customerId}')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chatService.getCustomerMessages(widget.customerId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final messages = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message['senderId'] == agentId;
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.orange : Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(message['text']),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send, color: Colors.orange),
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}
