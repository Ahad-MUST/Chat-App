import 'package:chat/widgets/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    final authenticateduser = FirebaseAuth.instance.currentUser!;
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, Chatsnapshot) {
        if (Chatsnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (!Chatsnapshot.hasData || Chatsnapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No messages found'),
          );
        }
        if (Chatsnapshot.hasError) {
          return const Center(
            child: Text('Something went wrong...'),
          );
        }
        final loadedmessages = Chatsnapshot.data!.docs;
        return ListView.builder(
          reverse: true,
          itemCount: loadedmessages.length,
          itemBuilder: (context, index) {
            final currentmessage = loadedmessages[index].data();
            final nextmessage = index + 1 < loadedmessages.length
                ? loadedmessages[index + 1]
                : null;
            final currentmessageID = currentmessage['userId'];
            final nextmessageID =
                nextmessage != null ? nextmessage['userId'] : null;
            final nextuserissame = nextmessageID == currentmessageID;
            if (nextuserissame) {
              return MessageBubble.next(
                  message: currentmessage['text'],
                  isMe: authenticateduser.uid == currentmessageID);
            } else {
              return MessageBubble.first(
                  userImage: currentmessage['userImage'],
                  username: currentmessage['username'],
                  message: currentmessage['text'],
                  isMe: authenticateduser.uid == currentmessageID);
            }
          },
        );
      },
    );
  }
}
