import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:reidle/choose_word.dart';
import 'package:reidle/recorder.dart';
import 'package:reidle/wordle.dart';

import 'db.dart';
import 'firebase_options.dart';

final isWebMobile = kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android);

late final Dictionary dict;

class Game {
  final Dictionary dictionary;
  final String theWord;
  final String theAnswer;
  final bool isReal;
  late final TimerProvider timerProvider;
  late final ReidleProvider reidleProvider;

  Game(this.dictionary, this.theWord, this.theAnswer, this.isReal) {
    timerProvider = TimerProvider();
    reidleProvider = ReidleProvider(dictionary, timerProvider, isReal, theWord, theAnswer)..start();
  }
}

class TimerProvider extends ChangeNotifier {
  Timer? timer;
  var penalty = const Duration(seconds: 0);
}

class ReidleProvider extends ChangeNotifier {
  DateTime? _startTime;
  DateTime? _endTime;
  final TimerProvider timerProvider;
  Submission? finalSubmission;

  bool get isFinished => finalSubmission != null;

  void onPressed(String k, BuildContext context) {
    if (k == '↵') {
      onSubmitted(context);
      return;
    }
    if (k == '␡') {
      controller.text = controller.text.substring(0, max(0, controller.text.length - 1));
    } else {
      controller.text += k;
    }
    controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
    notifyListeners();
  }

  List<String> guesses = [];

  Future<DocumentReference<Submission>>? created;

  final Dictionary dictionary;
  final bool isReal;
  final String theWord;
  final String theAnswer;

  ReidleProvider(this.dictionary, this.timerProvider, this.isReal, this.theWord, this.theAnswer) {
    String? last;
    controller.addListener(() {
      if (controller.text == last) {
        return;
      }
      recorder.add(Event.word(controller.text));
      last = controller.text;
    });
  }

  bool get isRunning => timerProvider.timer != null;

  final focus = FocusNode();
  final recorder = Recorder();
  final controller = TextEditingController();

  Duration get duration =>
      (_endTime ?? DateTime.now()).difference(_startTime ?? DateTime.now()) + timerProvider.penalty;

  void toggle() {
    (isRunning ? stop : start)();
    focus.requestFocus();
  }

  void start() {
    recorder.start();
    _startTime = DateTime.now();
    _endTime = null;
    timerProvider.penalty = const Duration(seconds: 0);
    guesses.clear();
    guesses.add(theWord);
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
        final duration = Duration(seconds: penalty);
        recorder.add(Event.penalty(duration));
        timerProvider.penalty += duration;
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
    final score = scoreWordle(theAnswer, guesses);
    final checker = checkWordle(theAnswer, score);
    if (checker.finished) {
      stop();
      finalSubmission = Submission(
        name: FirebaseAuth.instance.currentUser?.name ?? '',
        time: duration,
        submissionTime: DateTime.now().toUtc(),
        paste: score.paste,
        error: checker.error,
        penalty: timerProvider.penalty,
        uid: FirebaseAuth.instance.currentUser?.uid,
        events: recorder.events,
      );
      if (isReal) {
        created = db.submissions.add(finalSubmission!);
      }
      submissionSnackbar(context, finalSubmission!, theAnswer);
      notifyListeners();
      return;
    }
    if (checker.error?.isNotEmpty ?? false) {
      guesses.removeLast();
      return snack(checker.error ?? 'error', 10);
    }
    recorder.add(const Event.enter());
    notifyListeners();
    controller.clear();
    focus.requestFocus();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAuth.instance.signInAnonymously();
  dict = await dictionary;
  runApp(
    MultiProvider(
      providers: [
        StreamProvider<Submissions>.value(
            value: db.submissionsStream, initialData: Submissions([])),
        StreamProvider<User?>.value(
            value: FirebaseAuth.instance.userChanges(),
            initialData: FirebaseAuth.instance.currentUser)
      ],
      child: MaterialApp(
        home: MultiProvider(
          providers: [
            StreamProvider<Submissions>.value(
                value: db.submissionsStream, initialData: Submissions([])),
            StreamProvider<User?>.value(
                value: FirebaseAuth.instance.userChanges(),
                initialData: FirebaseAuth.instance.currentUser)
          ],
          child: const Home(),
        ),
      ),
    ),
  );
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

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Reidle", style: GoogleFonts.robotoMono())),
        drawer: const ReidleDrawer(),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            PracticeButton(),
            SizedBox(height: 16),
            PlayButton(),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(children: const [MyNameWidget()]),
          ),
        ));
  }
}

class PlayButton extends StatelessWidget {
  const PlayButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final hasName = Provider.of<User?>(context)?.displayName?.isNotEmpty ?? false;
    return FloatingActionButton(
      heroTag: "play",
      backgroundColor: hasName ? null : Colors.grey,
      onPressed: () => hasName
          ? Navigator.of(context).push(MaterialPageRoute(
              builder: (_) =>
                  GameWidget(game: Game(dict, dict.todaysWord, dict.todaysAnswer, true))))
          : ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("Must set name"))),
      child: const Icon(Icons.play_arrow),
    );
  }
}

class PracticeButton extends StatelessWidget {
  const PracticeButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: "practice",
      onPressed: () => pushPractice(context),
      child: const Icon(Icons.timer),
    );
  }
}

class MyNameWidget extends StatelessWidget {
  const MyNameWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: Provider.of<User?>(context)?.displayName ?? "",
      decoration: const InputDecoration(labelText: "My Name"),
      onFieldSubmitted: (s) => FirebaseAuth.instance.currentUser?.updateDisplayName(s),
    );
  }
}

void pushPractice(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => GameWidget(game: Game(dict, dict.randomWord(), dict.randomAnswer(), false))));
}

class HomeButton extends StatelessWidget {
  const HomeButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
        icon: const Icon(Icons.home));
  }
}

class TimerHeader extends StatelessWidget {
  const TimerHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final reidle = Provider.of<ReidleProvider>(context, listen: false);
    final timer = Provider.of<TimerProvider>(context);
    final submissions = Provider.of<Submissions>(context);
    return Padding(
      padding: const EdgeInsets.only(right: 30.0),
      child: Row(
          children: <Widget>[
        Text(reidle.isReal ? "Play" : "Practice"),
        if (reidle.isReal && submissions.bestTime != null)
          Text(submissions.bestTime?.stopwatchString ?? '',
              style: GoogleFonts.robotoMono(color: Colors.green.shade200)),
        Text(reidle.duration.stopwatchString, style: GoogleFonts.robotoMono()),
        if (timer.penalty > const Duration())
          Text(timer.penalty.stopwatchString,
              style: GoogleFonts.robotoMono(color: Colors.red.shade200))
      ].separate(const Spacer()).toList()),
    );
  }
}

class GameWidget extends StatelessWidget {
  final Game game;
  const GameWidget({required this.game, super.key});

  bool get isReal => game.isReal;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: game.timerProvider),
          ChangeNotifierProvider.value(value: game.reidleProvider),
        ],
        child: Scaffold(
            appBar: AppBar(
              title: const TimerHeader(),
              actions: const [HomeButton()],
            ),
            floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
            floatingActionButton: GameFloatingActionButton(game: game),
            drawer: const ReidleDrawer(),
            body: const WordleGameWidget()));
  }
}

class GameFloatingActionButton extends StatelessWidget {
  final Game game;
  const GameFloatingActionButton({Key? key, required this.game}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final reidle = Provider.of<ReidleProvider>(context);
    if (reidle.isFinished) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          PracticeButton(),
          SizedBox(height: 16),
          UndoButton(),
        ],
      );
    }
    return const SizedBox();
  }
}

class UndoButton extends StatelessWidget {
  const UndoButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final reidle = Provider.of<ReidleProvider>(context);
    if (reidle.created != null) {
      return FloatingActionButton(
          child: const Icon(Icons.delete),
          onPressed: () {
            reidle.undo();
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text("Removed result")));
          });
    }
    return const SizedBox();
  }
}

class ReidleDrawer extends StatelessWidget {
  const ReidleDrawer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(child: Builder(builder: (context) {
      return ListView(children: [
        ListTile(
            title: const Text("Home"),
            onTap: () => Navigator.of(context).popUntil((route) => route.isFirst)),
        ListTile(
            title: const Text('History'),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HistoryPage()));
            })
      ]);
    }));
  }
}

class HistoryPage extends StatelessWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
            title: const Text("History"),
            actions: const [HomeButton()],
            bottom: const TabBar(
              tabs: [Text("History"), Text("Leaderboard")],
            )),
        drawer: const ReidleDrawer(),
        body: TabBarView(
            children: [
          HistoryDataTable(),
          LeaderboardDataTable(),
        ].map((e) => SingleChildScrollView(child: e)).toList()),
      ),
    );
  }
}

class WordleGameWidget extends StatelessWidget {
  const WordleGameWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final reidle = Provider.of<ReidleProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Column(
          children: [
            WordleWidget(reidle.theAnswer, reidle.guesses),
            ...(reidle.isRunning
                ? [
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
                    const Spacer(),
                    WordleKeyboardWidget(reidle.theAnswer, reidle.guesses,
                        onPressed: (s) => reidle.onPressed(s, context))
                  ]
                : [])
          ],
        ),
      ),
    );
  }
}

extension D on DateTime {
  String get dateString => '$month/$day';
}

extension<T> on Iterable<T> {
  Iterable<T> separate<S extends T>(S w) sync* {
    if (isNotEmpty) yield first;
    for (final e in skip(1)) {
      yield w;
      yield e;
    }
  }
}

void submissionSnackbar(BuildContext context, Submission submission, [String? todaysAnswer]) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text([submission.error ?? 'Win', todaysAnswer].where((x) => x != null).join(': '))));
}

class PlaybackWidget extends StatefulWidget {
  final List<RecorderEvent> playback;
  final Game game;
  const PlaybackWidget(this.playback, this.game, {Key? key}) : super(key: key);

  @override
  State<PlaybackWidget> createState() => _PlaybackWidgetState();
}

class _PlaybackWidgetState extends State<PlaybackWidget> {
  final List<String> guesses = [""];
  RecorderEvent? event;
  @override
  void initState() {
    super.initState();
    bump(widget.playback.iterator);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        color: event?.event.when(
                word: (_) => Colors.white,
                enter: () => Colors.green.shade100,
                penalty: (_) => Colors.red.shade300) ??
            Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: WordleWidget(widget.game.theAnswer, guesses),
        ));
  }

  void bump(Iterator<RecorderEvent> iterator) {
    if (!iterator.moveNext()) {
      return;
    }
    final value = iterator.current;
    Future.delayed(value.duration, () {
      setState(() {
        event = value;
        value.event.whenOrNull(
            word: (word) {
              guesses.removeLast();
              guesses.add(word.padRight(5, ' ').truncate(5));
            },
            enter: () => guesses.add(""));
      });
      bump(iterator);
    });
  }
}

extension on String {
  String truncate(int length) => length < this.length ? substring(0, length) : this;
}

class LeaderboardDataTable extends StatelessWidget {
  const LeaderboardDataTable({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DataTable(
        columns: [
          'name',
          'wins',
        ].map((s) => DataColumn(label: Text(s))).toList(),
        rows: Provider.of<Submissions>(context)
            .leaderboard
            .map((e) => DataRow(
                  cells: [DataCell(Text(e.key)), DataCell(Text(e.value.toString()))],
                ))
            .toList());
  }
}

class HistoryDataTable extends StatelessWidget {
  const HistoryDataTable({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DataTable(
        columnSpacing: 20,
        columns: [
          'name',
          'date',
          'time',
          'pen',
          'paste',
        ].map((s) => DataColumn(label: Text(s))).toList(),
        rows: Provider.of<Submissions>(context)
            .submissions
            .where((e) =>
                DateTime.now().toUtc().difference(e.submission.submissionTime) <
                const Duration(days: 10))
            .map((e) => DataRow(
                  onLongPress: e.submission.error?.isNotEmpty ?? false
                      ? () => submissionSnackbar(context, e.submission)
                      : null,
                  color: MaterialStateProperty.all(e.isWinner
                      ? Colors.green.shade100
                      : !e.submission.won
                          ? Colors.red.shade100
                          : e.submission.name.toLowerCase().trim() ==
                                  FirebaseAuth.instance.currentUser?.name.toLowerCase().trim()
                              ? Colors.yellow.shade100
                              : Colors.white),
                  cells: [
                    DataCell(
                        Text(e.submission.name.substring(0, min(e.submission.name.length, 7)))),
                    DataCell(Text(e.submission.submissionTime.dateString,
                        style: TextStyle(
                            fontWeight: e.submission.submissionTime.dateString ==
                                    DateTime.now().toUtc().dateString
                                ? FontWeight.bold
                                : FontWeight.normal))),
                    DataCell(Text(e.submission.time.stopwatchString)),
                    DataCell(() {
                      final seconds = e.submission.penalty?.inSeconds ?? 0;
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
            .toList());
  }
}
