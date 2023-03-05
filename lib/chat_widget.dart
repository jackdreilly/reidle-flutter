import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:reidle/main.dart';

class ChatWidget extends StatefulWidget {
  const ChatWidget({super.key});

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  static String extractChatDate(Map<String, dynamic> e) {
    const splitLength = 5;

    return (e['date'] as String? ?? '')
        .substring(splitLength)
        .split('.')
        .first
        .replaceAll('T', '\n');
  }

  final controller = TextEditingController();

  static final collection = FirebaseFirestore.instance.collection('chats');
  final stream = collection
      .orderBy('date', descending: true)
      .where(
        'date',
        isGreaterThanOrEqualTo:
            DateTime.now().toUtc().subtract(const Duration(days: 30)).toIso8601String(),
      )
      .snapshots()
      .map((event) => event.docs.map((e) => {'ref': e.reference, ...e.data()}).toList());

  final focusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    update();
  }

  void update() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid ?? "")
        .set({'chatLastVisited': DateTime.now().toUtc().toIso8601String()});
  }

  @override
  void dispose() {
    update();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat"),
        actions: const [HomeButton()],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              autofocus: true,
              onSubmitted: submitMessage,
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: stream,
              builder: (context, snapshot) {
                return ListView(
                  children: snapshot.data?.map((e) {
                        final currentUser = FirebaseAuth.instance.currentUser;

                        return ListTile(
                          leading: Text(extractChatDate(e)),
                          title: Text(e['message'] ?? ''),
                          subtitle: Text(e['name'] ?? ""),
                          trailing:
                              e['uid'] == currentUser?.uid || e['name'] == currentUser?.displayName
                                  ? IconButton(
                                      onPressed: () => (e['ref'] as DocumentReference).delete(),
                                      icon: const Icon(Icons.delete),
                                    )
                                  : null,
                        );
                      }).toList() ??
                      [],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void submitMessage(message) {
    update();
    if (message.trim().isEmpty) {
      return;
    }
    var currentUser = FirebaseAuth.instance.currentUser;
    collection.add({
      'date': DateTime.now().toUtc().toIso8601String(),
      'message': message,
      'uid': currentUser?.uid ?? "",
      'name': currentUser?.displayName ?? "...",
    }).ignore();
    controller.clear();
    focusNode.requestFocus();
  }
}
