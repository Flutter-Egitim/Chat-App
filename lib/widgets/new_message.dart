import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submitMessage() async {
    final String enteredMessage = _controller.text;

    if (enteredMessage.trim().isEmpty) {
      return;
    }

    final userId = FirebaseAuth.instance.currentUser!.uid;
    final userData = await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .get();

    await FirebaseFirestore.instance.collection("chat").add({
      "text": enteredMessage,
      "createdAt": Timestamp.now(),
      "userId": userId,
      "username": userData.data()!["username"],
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 15, bottom: 15),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
              decoration: InputDecoration(labelText: "Send a message"),
            ),
          ),
          IconButton(onPressed: _submitMessage, icon: Icon(Icons.send)),
        ],
      ),
    );
  }
}
