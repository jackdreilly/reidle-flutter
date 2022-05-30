import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:reidle/choose_word.dart';
import 'package:reidle/wordle.dart';

import 'db.dart';
import 'firebase_options.dart';
import 'package:flutter/foundation.dart';

final isWebMobile = kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android);

class TimerProvider extends ChangeNotifier {
  DateTime? _startTime;
  DateTime? _endTime;

  void onPressed(String k, BuildContext context) {
    if (k == '↵') {
      onSubmitted(context);
      return;
    }
    if (k == '␡') {
      if (controller.text.isEmpty) {
        return;
      }
      controller.text = controller.text.substring(0, controller.text.length - 1);
    } else {
      controller.text += k;
    }
    controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
    notifyListeners();
  }

  Timer? _timer;

  List<String> guesses = [];

  Future<DocumentReference<Submission>>? created;

  final Dictionary dictionary;

  final Stream<Submissions> submissions = db.submissions;
  get todaysWord => dictionary.todaysWord;
  get todaysAnswer => dictionary.todaysAnswer;

  TimerProvider(this.dictionary);

  bool get isRunning => _timer != null;

  final focus = FocusNode();
  final controller = TextEditingController();

  Duration get duration => (_endTime ?? DateTime.now()).difference(_startTime ?? DateTime.now());

  void toggle() {
    (isRunning ? stop : start)();
  }

  void start() {
    _startTime = DateTime.now();
    _endTime = null;
    guesses.clear();
    guesses.add(todaysWord);
    notifyListeners();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      notifyListeners();
    });
  }

  void stop() {
    _endTime = DateTime.now();
    _timer?.cancel();
    _timer = null;
    notifyListeners();
  }

  void undo() async {
    (await created)?.delete();
    created = null;
    guesses.clear();
    notifyListeners();
  }

  onSubmitted(BuildContext context) {
    final s = controller.text;
    String? getErrorText() {
      if (FirebaseAuth.instance.currentUser?.displayName?.isEmpty ?? true) return "Must set name";
      if (controller.text.isEmpty) return null;
      if (controller.text.length != 5) return 'Must be 5 letters';
      if (!dictionary.isValid(controller.text)) return 'Not a word';
      return null;
    }

    final errorText = getErrorText();
    if ((errorText?.length ?? 0) > 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorText!)));
      focus.requestFocus();
      return;
    }

    FirebaseAnalytics.instance.logEvent(name: "guess", parameters: {'guess': s});
    guesses.add(s);
    final score = scoreWordle(todaysAnswer, guesses);
    final checker = checkWordle(todaysAnswer, score);
    if (checker.finished) {
      stop();
      final response =
          db.add(FirebaseAuth.instance.currentUser!, duration, score.paste, checker.error);
      created = response.key;
      submissionDialog(context, response.value);
      notifyListeners();
      return;
    }
    if ((checker.error?.length ?? 0) > 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(checker.error!)));
      guesses.removeLast();
      focus.requestFocus();
      return;
    }
    notifyListeners();
    controller.clear();
    focus.requestFocus();
  }
}

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAuth.instance.signInAnonymously();
  WidgetsFlutterBinding.ensureInitialized();
  final dict = await dictionary;
  runApp(ChangeNotifierProvider.value(
      value: TimerProvider(dict),
      builder: (_, __) => Consumer<TimerProvider>(builder: (_, t, __) => MyApp(t))));
}

class MyApp extends StatelessWidget {
  final TimerProvider timer;

  const MyApp(this.timer, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            body: SingleChildScrollView(
      child: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: StreamBuilder<User?>(
              stream: FirebaseAuth.instance.userChanges(),
              builder: (context, userSnapshot) => userSnapshot.data == null
                  ? const Text("loading")
                  : Column(
                      children: [
                        Card(
                          margin: const EdgeInsets.all(8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (timer.created != null)
                                ElevatedButton.icon(
                                    onPressed: timer.undo,
                                    icon: const Icon(Icons.undo),
                                    label: const Text("Undo")),
                              if (timer.guesses.isEmpty)
                                ElevatedButton.icon(
                                    label: const Text("Play"),
                                    onPressed: timer.toggle,
                                    icon: const Icon(Icons.play_arrow)),
                              if (timer.guesses.isNotEmpty)
                                Card(
                                    margin: const EdgeInsets.all(8),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(timer.duration.stopwatchString,
                                          style: GoogleFonts.robotoMono(fontSize: 20)),
                                    )),
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 200),
                                child: TextFormField(
                                    autofocus: (userSnapshot.data?.displayName?.length ?? 0) == 0,
                                    initialValue: userSnapshot.data?.displayName ?? '',
                                    decoration: const InputDecoration(labelText: "My Name"),
                                    maxLength: 10,
                                    maxLengthEnforcement: MaxLengthEnforcement.enforced,
                                    onFieldSubmitted: (s) async {
                                      userSnapshot.data?.updateDisplayName(s);
                                      FirebaseAnalytics.instance
                                          .logEvent(name: "set_username", parameters: {
                                        'name': s,
                                      });
                                    }),
                              ),
                            ]
                                .map((x) => Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: x,
                                    ))
                                .toList(),
                          ),
                        ),
                        WordleGameWidget(timer),
                        StreamBuilder<Submissions>(
                          stream: timer.submissions,
                          builder: (_, s) => Column(
                            children: [
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxHeight: 300),
                                child: Card(
                                  child: SingleChildScrollView(
                                    child: DataTable(
                                      columns: [
                                        'name',
                                        'date',
                                        'time',
                                        'paste',
                                      ].map((s) => DataColumn(label: Text(s))).toList(),
                                      rows: s.data?.submissions
                                              .where((e) =>
                                                  DateTime.now()
                                                      .toUtc()
                                                      .difference(e.submission.submissionTime) <
                                                  const Duration(days: 10))
                                              .map((e) => DataRow(
                                                    onLongPress: e.submission.error?.isNotEmpty ??
                                                            false
                                                        ? () =>
                                                            submissionDialog(context, e.submission)
                                                        : null,
                                                    color: MaterialStateProperty.all(e.isWinner
                                                        ? Colors.green.shade100
                                                        : !e.submission.won
                                                            ? Colors.red.shade100
                                                            : e.submission.name ==
                                                                    userSnapshot.data?.name
                                                                ? Colors.yellow.shade100
                                                                : Colors.white),
                                                    cells: [
                                                      DataCell(Text(e.submission.name)),
                                                      DataCell(Text(
                                                          e.submission.submissionTime.dateString,
                                                          style: TextStyle(
                                                              fontWeight: e
                                                                          .submission
                                                                          .submissionTime
                                                                          .dateString ==
                                                                      DateTime.now()
                                                                          .toUtc()
                                                                          .dateString
                                                                  ? FontWeight.bold
                                                                  : FontWeight.normal))),
                                                      DataCell(
                                                          Text(e.submission.time.stopwatchString)),
                                                      DataCell(Text(
                                                        e.submission.paste ?? "",
                                                        style: const TextStyle(fontSize: 6),
                                                      )),
                                                    ],
                                                  ))
                                              .toList() ??
                                          [],
                                    ),
                                  ),
                                ),
                              ),
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxHeight: 300),
                                child: Card(
                                  child: SingleChildScrollView(
                                    child: DataTable(
                                      columns: [
                                        'name',
                                        'wins',
                                      ].map((s) => DataColumn(label: Text(s))).toList(),
                                      rows: s.data?.leaderboard
                                              .map((e) => DataRow(
                                                    cells: [
                                                      DataCell(Text(e.key)),
                                                      DataCell(Text(e.value.toString()))
                                                    ],
                                                  ))
                                              .toList() ??
                                          [],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      )),
    )));
  }
}

class WordleGameWidget extends StatelessWidget {
  final TimerProvider timer;
  const WordleGameWidget(this.timer, {Key? key}) : super(key: key);

  List<String> get guesses => timer.guesses;

  @override
  Widget build(BuildContext context) {
    return timer.guesses.isEmpty
        ? Container()
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: WordleWidget(timer.todaysAnswer, guesses),
              ),
              if (timer.isRunning)
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 150),
                  child: TextField(
                      keyboardType: isWebMobile ? TextInputType.none : null,
                      maxLines: 1,
                      autofocus: true,
                      focusNode: timer.focus,
                      controller: timer.controller,
                      style: GoogleFonts.robotoMono(fontSize: 48),
                      onSubmitted: (_) => timer.onSubmitted(context)),
                ),
              if (timer.isRunning)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: WordleKeyboardWidget(timer.todaysAnswer, guesses,
                      onPressed: (s) => timer.onPressed(s, context)),
                )
            ],
          );
  }
}

extension D on DateTime {
  String get dateString => '$month/$day';
}

Future<dynamic> submissionDialog(BuildContext context, Submission submission) {
  return showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: Text("${submission.name}'s submission"),
            content: Text(submission.error ?? 'Win'),
            actions: [
              MaterialButton(
                  onPressed: () => Navigator.of(context).pop(), child: const Text("Close"))
            ],
          ));
}
