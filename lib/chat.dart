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
  final controller = TextEditingController();

  static final collection = FirebaseFirestore.instance.collection('chats');
  late Stream<List<Map<String, dynamic>>> stream;

  final focusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    stream = collection
        .orderBy('date', descending: true)
        .where('date',
            isGreaterThanOrEqualTo:
                DateTime.now().toUtc().subtract(const Duration(days: 30)).toIso8601String())
        .snapshots()
        .map((event) => event.docs.map((e) => e.data()).toList());
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
                onSubmitted: (message) {
                  collection.add({
                    'date': DateTime.now().toUtc().toIso8601String(),
                    'message': message,
                    'uid': FirebaseAuth.instance.currentUser?.uid ?? "",
                    'name': FirebaseAuth.instance.currentUser?.displayName ?? "...",
                  });
                  controller.clear();
                  focusNode.requestFocus();
                }),
          ),
          Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                  stream: stream,
                  builder: (context, snapshot) {
                    return ListView(
                      children: snapshot.data
                              ?.map((e) => ListTile(
                                    leading: Text(e['name'] ?? ""),
                                    title: Text(e['message'] ?? ''),
                                    trailing: Text(e['date'] ?? ''),
                                  ))
                              .toList() ??
                          [],
                    );
                  }))
        ],
      ),
    );
  }
}
