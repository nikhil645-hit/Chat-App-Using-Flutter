import 'package:flutter/material.dart';
import 'dart:async';

void main() => runApp(SimpleChatApp());

class SimpleChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Chat (Beginner)',
      debugShowCheckedModeBanner: false,
      home: ChatPage(),
    );
  }
}

// Very tiny message model
class Message {
  final String text;
  final bool isMe;
  final DateTime time;
  Message({required this.text, required this.isMe, DateTime? time})
      : this.time = time ?? DateTime.now();
}

class ChatPage extends StatefulWidget {
  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Message> _messages = [
    Message(text: "Hello! This is a demo chat.", isMe: false),
    Message(text: "Hi! I made this app.", isMe: true),
  ];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(Message(text: text, isMe: true));
    });
    _controller.clear();
    _scrollToBottom();

    // tiny auto-reply to make it feel like chat (beginnerish)
    Future.delayed(Duration(milliseconds: 700), () {
      setState(() {
        _messages.add(Message(text: "Auto-reply: Got \"$text\"", isMe: false));
      });
      _scrollToBottom();
    });
  }

  void _deleteMessage(int index) {
    setState(() {
      _messages.removeAt(index);
    });
  }

  void _scrollToBottom() {
    // small delay so UI updates first
    Future.delayed(Duration(milliseconds: 50), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildMessageTile(Message msg, int index) {
    final align = msg.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bg = msg.isMe ? Colors.lightBlueAccent.withOpacity(0.9) : Colors.grey[300];
    final txtColor = msg.isMe ? Colors.white : Colors.black87;
    final radius = msg.isMe
        ? BorderRadius.only(
      topLeft: Radius.circular(12),
      topRight: Radius.circular(12),
      bottomLeft: Radius.circular(12),
    )
        : BorderRadius.only(
      topLeft: Radius.circular(12),
      topRight: Radius.circular(12),
      bottomRight: Radius.circular(12),
    );

    return GestureDetector(
      onLongPress: () {
        // simple delete on long press
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("Delete message?"),
            content: Text("Do you want to delete this message?"),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _deleteMessage(index);
                },
                child: Text("Delete"),
              ),
            ],
          ),
        );
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          crossAxisAlignment: align,
          children: [
            Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: radius,
              ),
              child: Column(
                crossAxisAlignment: align,
                children: [
                  Text(msg.text, style: TextStyle(color: txtColor)),
                  SizedBox(height: 6),
                  Text(
                    _formatTime(msg.time),
                    style: TextStyle(fontSize: 10, color: txtColor.withOpacity(0.8)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime t) {
    final hh = t.hour.toString().padLeft(2, '0');
    final mm = t.minute.toString().padLeft(2, '0');
    return "$hh:$mm";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Simple Chat (Beginner)"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              padding: EdgeInsets.symmetric(vertical: 8),
              itemBuilder: (context, index) {
                return _buildMessageTile(_messages[index], index);
              },
            ),
          ),

          // input area
          SafeArea(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: "Type a message",
                        border: OutlineInputBorder(),
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _sendMessage,
                    child: Icon(Icons.send),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
