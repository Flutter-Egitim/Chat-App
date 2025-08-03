import 'package:chat_app_flutter/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticatedUserId = FirebaseAuth.instance.currentUser!.uid;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("chat")
          .orderBy("createdAt", descending: true)
          .snapshots(),
      builder: (context, chatSnapshots) {
        if (chatSnapshots.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty) {
          return Center(child: Text("No messages"));
        }

        if (chatSnapshots.hasError) {
          return Center(child: Text("Something went wrong"));
        }

        final loadedMessages = chatSnapshots.data!.docs;

        return ListView.builder(
          reverse: true,
          padding: EdgeInsets.only(bottom: 40, left: 12, right: 12),
          itemCount: loadedMessages.length,
          itemBuilder: (context, index) {
            final chatMessage = loadedMessages[index].data();
            final nextChatMessage = index + 1 < loadedMessages.length
                ? loadedMessages[index + 1]
                : null;
            final currentMessageUserId = chatMessage["userId"];
            final nextMessageUserId = nextChatMessage != null
                ? nextChatMessage["userId"]
                : null;
            final nextUserIsSame = nextMessageUserId == currentMessageUserId;
            if (nextUserIsSame) {
              return MessageBubble.next(
                message: chatMessage["text"],
                isMe: authenticatedUserId == currentMessageUserId,
              );
            } else {
              return MessageBubble.first(
                username: chatMessage["username"],
                message: chatMessage["text"],
                isMe: authenticatedUserId == currentMessageUserId,
              );
            }
          },
        );
      },
    );
  }
}
