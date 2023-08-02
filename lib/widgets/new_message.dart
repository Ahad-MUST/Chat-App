import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _messagecontroller = TextEditingController();
  @override
  void dispose() {
    _messagecontroller.dispose();
    super.dispose();
  }

  void _submit() async {
    final enteredmessage = _messagecontroller.text;
    if (enteredmessage.trim().isEmpty) {
      return;
    }
    _messagecontroller.clear();
    FocusScope.of(context).unfocus();
    final currentuser = FirebaseAuth.instance.currentUser;
    final userdata = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentuser!.uid)
        .get();

    FirebaseFirestore.instance.collection('chat').add({
      'text': enteredmessage,
      'createdAt': Timestamp.now(),
      'userId': currentuser!.uid,
      'username': userdata.data()!['username'],
      'userImage': userdata.data()!['ImageURL'],
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 2, bottom: 15),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messagecontroller,
              enableSuggestions: true,
              autocorrect: true,
              textCapitalization: TextCapitalization.sentences,
              decoration:
                  const InputDecoration(labelText: 'Enter a message...'),
            ),
          ),
          IconButton(
            onPressed: _submit,
            icon: Icon(
              Icons.send,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
