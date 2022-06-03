import 'package:reidle/secrets.dart';
import 'package:sendgrid_mailer/sendgrid_mailer.dart';
import 'dart:async';
import 'dart:math';

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
  Timer? timer;
  var penalty = const Duration(seconds: 0);
}

class ReidleProvider extends ChangeNotifier {
  DateTime? _startTime;
  DateTime? _endTime;
  final TimerProvider timerProvider;

  final usernameController = () {
    final controller = TextEditingController();
    FirebaseAuth.instance
        .userChanges()
        .where((event) => event?.uid.isNotEmpty ?? false)
        .first
        .then((value) => controller.text = value?.displayName ?? '');
    return controller;
  }();

  final usernameFocus = FocusNode();

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

  List<String> guesses = [];

  Future<DocumentReference<Submission>>? created;

  final Dictionary dictionary;

  get todaysWord => dictionary.todaysWord;
  get todaysAnswer => dictionary.todaysAnswer;

  ReidleProvider(this.dictionary, this.timerProvider) {
    usernameFocus.addListener(() {
      if (!usernameFocus.hasFocus &&
          (FirebaseAuth.instance.currentUser?.displayName ?? '') != usernameController.text) {
        usernameSubmit();
      }
    });
  }

  bool get isRunning => timerProvider.timer != null;

  final focus = FocusNode();
  final controller = TextEditingController();

  Duration get duration =>
      (_endTime ?? DateTime.now()).difference(_startTime ?? DateTime.now()) + timerProvider.penalty;

  void toggle() {
    (isRunning ? stop : start)();
    focus.requestFocus();
  }

  void start() {
    _startTime = DateTime.now();
    _endTime = null;
    timerProvider.penalty = const Duration(seconds: 0);
    guesses.clear();
    guesses.add(todaysWord);
    notifyListeners();
    timerProvider.timer = Timer.periodic(const Duration(seconds: 1), (reidle) {
      timerProvider.notifyListeners();
    });
  }

  void stop() {
    _endTime = DateTime.now();
    timerProvider.timer?.cancel();
    timerProvider.timer = null;
    notifyListeners();
  }

  void undo() async {
    (await created)?.delete();
    created = null;
    guesses.clear();
    notifyListeners();
  }

  onSubmitted(BuildContext context) {
    focus.requestFocus();
    final s = controller.text;
    void snack(String s, [int? penalty]) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s)));
      if (penalty != null) {
        timerProvider.penalty += Duration(seconds: penalty);
        notifyListeners();
      }
    }

    if (FirebaseAuth.instance.currentUser?.displayName?.isEmpty ?? true) {
      return snack("Must set name");
    }
    if (controller.text.isEmpty) return null;
    if (controller.text.length != 5) return snack('Must be 5 letters');
    if (!dictionary.isValid(controller.text)) return snack('Not a word', 5);

    FirebaseAnalytics.instance.logEvent(name: "guess", parameters: {'guess': s});
    guesses.add(s);
    final score = scoreWordle(todaysAnswer, guesses);
    final checker = checkWordle(todaysAnswer, score);
    if (checker.finished) {
      stop();
      final submission = Submission(
        name: FirebaseAuth.instance.currentUser?.name ?? '',
        time: duration,
        submissionTime: DateTime.now().toUtc(),
        paste: score.paste,
        error: checker.error,
        penalty: timerProvider.penalty,
      );
      created = db.submissions.add(submission);

      Mailer(sendgridApiKey).send(Email(
          [
            const Personalization([Address('reidle@googlegroups.com')])
          ],
          const Address('jackdreilly@gmail.com'),
          'Update',
          content: [
            Content(
                'text/plain',
                {
                  'name': submission.name,
                  'date': submission.submissionTime.toIso8601String(),
                  'time': submission.time.stopwatchString,
                  'penalty': submission.penalty?.inSeconds,
                  'error': submission.error
                }
                    .entries
                    .where((x) => x.value?.toString().isNotEmpty ?? false)
                    .map((x) => [x.key, x.value].join(': '))
                    .join('\n'))
          ]));
      submissionSnackbar(context, submission, todaysAnswer);
      notifyListeners();
      return;
    }
    if (checker.error?.isNotEmpty ?? false) {
      guesses.removeLast();
      return snack(checker.error ?? 'error', 10);
    }
    notifyListeners();
    controller.clear();
    focus.requestFocus();
  }

  void usernameSubmit() {
    FirebaseAuth.instance.currentUser?.updateDisplayName(usernameController.text);
    FirebaseAnalytics.instance.logEvent(name: "set_username", parameters: {
      'name': usernameController.text,
    });
  }
}

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAuth.instance.signInAnonymously();
  WidgetsFlutterBinding.ensureInitialized();
  final dict = await dictionary;
  final timerProvider = TimerProvider();
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider.value(value: timerProvider),
    ChangeNotifierProvider.value(value: ReidleProvider(dict, timerProvider))
  ], child: const MyApp()));
}

typedef TimerBuilder = Widget? Function(ReidleProvider reidle, BuildContext context);

class TimerWidget extends StatelessWidget {
  final TimerBuilder builder;

  const TimerWidget(this.builder, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return builder(Provider.of<ReidleProvider>(context), context) ?? Container();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 300),
                          child: Card(
                            margin: const EdgeInsets.all(8),
                            child:
                                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              TimerWidget((reidle, context) => (reidle.created == null)
                                  ? null
                                  : Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ElevatedButton.icon(
                                          onPressed: reidle.undo,
                                          icon: const Icon(Icons.undo),
                                          label: const Text("Undo")),
                                    )),
                              TimerWidget((reidle, context) => reidle.guesses.isNotEmpty
                                  ? null
                                  : Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ElevatedButton.icon(
                                          label: const Text("Play"),
                                          onPressed: reidle.toggle,
                                          icon: const Icon(Icons.play_arrow)),
                                    )),
                              TimerWidget(
                                (reidle, context) => (reidle.guesses.isEmpty)
                                    ? null
                                    : Consumer<TimerProvider>(builder: (context, _, __) {
                                        return Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            children: [
                                              Card(
                                                  margin: const EdgeInsets.all(8),
                                                  child: Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Text(reidle.duration.stopwatchString,
                                                        style:
                                                            GoogleFonts.robotoMono(fontSize: 20)),
                                                  )),
                                              if (reidle.timerProvider.penalty >
                                                  const Duration(seconds: 0))
                                                Card(
                                                    margin: const EdgeInsets.all(8),
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: Text(
                                                          reidle.timerProvider.penalty
                                                              .stopwatchString,
                                                          style: GoogleFonts.robotoMono(
                                                              fontSize: 20, color: Colors.red)),
                                                    )),
                                            ],
                                          ),
                                        );
                                      }),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TimerWidget(
                                    (reidle, context) => TextFormField(
                                      focusNode: reidle.usernameFocus,
                                      controller: reidle.usernameController,
                                      autofocus: (userSnapshot.data?.displayName?.length ?? 0) == 0,
                                      decoration: const InputDecoration(labelText: "My Name"),
                                      maxLength: 10,
                                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                                      onFieldSubmitted: (_) => reidle.usernameSubmit(),
                                    ),
                                  ),
                                ),
                              ),
                            ]),
                          ),
                        ),
                        TimerWidget((reidle, context) => WordleGameWidget(reidle)),
                        StreamBuilder<Submissions>(
                          stream: db.submissionsStream,
                          builder: (_, s) => Column(
                            children: [
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxHeight: 300),
                                child: Card(
                                  child: SingleChildScrollView(
                                    child: DataTable(
                                      columnSpacing: 20,
                                      columns: [
                                        'name',
                                        'date',
                                        'time',
                                        'pen',
                                        'paste',
                                      ].map((s) => DataColumn(label: Text(s))).toList(),
                                      rows: s.data?.submissions
                                              .where((e) =>
                                                  DateTime.now()
                                                      .toUtc()
                                                      .difference(e.submission.submissionTime) <
                                                  const Duration(days: 10))
                                              .map((e) => DataRow(
                                                    onLongPress:
                                                        e.submission.error?.isNotEmpty ?? false
                                                            ? () => submissionSnackbar(
                                                                context, e.submission)
                                                            : null,
                                                    color: MaterialStateProperty.all(e.isWinner
                                                        ? Colors.green.shade100
                                                        : !e.submission.won
                                                            ? Colors.red.shade100
                                                            : e.submission.name
                                                                        .toLowerCase()
                                                                        .trim() ==
                                                                    userSnapshot.data?.name
                                                                        .toLowerCase()
                                                                        .trim()
                                                                ? Colors.yellow.shade100
                                                                : Colors.white),
                                                    cells: [
                                                      DataCell(Text(e.submission.name.substring(
                                                          0, min(e.submission.name.length, 7)))),
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
                                                      DataCell(() {
                                                        final seconds =
                                                            e.submission.penalty?.inSeconds ?? 0;
                                                        if (seconds < 1) {
                                                          return const Text("");
                                                        }
                                                        return Text("$seconds");
                                                      }()),
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
  final ReidleProvider reidle;
  const WordleGameWidget(this.reidle, {Key? key}) : super(key: key);

  List<String> get guesses => reidle.guesses;

  @override
  Widget build(BuildContext context) {
    return reidle.guesses.isEmpty
        ? Container()
        : Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: WordleWidget(reidle.todaysAnswer, guesses),
              ),
              if (reidle.isRunning)
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 150),
                  child: TextField(
                      keyboardType: isWebMobile ? TextInputType.none : null,
                      maxLines: 1,
                      autofocus: true,
                      focusNode: reidle.focus,
                      controller: reidle.controller,
                      style: GoogleFonts.robotoMono(fontSize: 48),
                      onSubmitted: (_) => reidle.onSubmitted(context)),
                ),
              if (reidle.isRunning)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: WordleKeyboardWidget(reidle.todaysAnswer, guesses,
                      onPressed: (s) => reidle.onPressed(s, context)),
                )
            ],
          );
  }
}

extension D on DateTime {
  String get dateString => '$month/$day';
}

void submissionSnackbar(BuildContext context, Submission submission, [String? todaysAnswer]) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text([submission.error ?? 'Win', todaysAnswer].where((x) => x != null).join(': '))));
}
