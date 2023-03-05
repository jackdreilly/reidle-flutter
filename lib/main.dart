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
import 'package:reidle/chat_widget.dart';
import 'package:reidle/choose_word.dart';
import 'package:reidle/extensions.dart';
import 'package:reidle/recorder.dart';
import 'package:reidle/wordle.dart';
import 'package:rxdart/rxdart.dart';
import 'package:url_launcher/url_launcher.dart';

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
      if (controller.text == last || controller.text.isEmpty) {
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
    controller.clear();
    void snack(String s, [int? penalty]) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(s)));
      if (penalty != null) {
        final duration = Duration(seconds: penalty);
        recorder.add(Event.penalty(duration));
        timerProvider.penalty += duration;
        notifyListeners();
      }
    }

    if (FirebaseAuth.instance.currentUser?.displayName?.isEmpty ?? true && isReal) {
      return snack("Must set name");
    }
    if (s.isEmpty) return null;
    if (s.length != 5) return snack('Must be 5 letters');
    if (!dictionary.isValid(s)) return snack('Not a word', 5);

    FirebaseAnalytics.instance.logEvent(name: "guess", parameters: {'guess': s});
    if (guesses.contains(s)) {
      return;
    }
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
        answer: theAnswer,
        guesses: List.from(guesses),
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
        ChangeNotifierProvider.value(value: burk),
        StreamProvider<Submissions>.value(
            value: db.submissionsStream, initialData: Submissions([])),
        StreamProvider<User?>.value(
            value: FirebaseAuth.instance.userChanges(),
            initialData: FirebaseAuth.instance.currentUser)
      ],
      child: MaterialApp(
        home: const Home(),
        theme: ThemeData(
          useMaterial3: true,
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
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            title: Text("Reidle Week ${DateTime.now().reidleWeek} Day ${DateTime.now().reidleDay}",
                style: GoogleFonts.robotoMono())),
        drawer: const ReidleDrawer(),
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        floatingActionButton: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            ChatButton(),
            SizedBox(height: 16),
            HistoryButton(),
            SizedBox(height: 16),
            PracticeButton(),
            SizedBox(height: 16),
            PlayButton(),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(children: const [MyNameWidget()]),
                ),
              ),
              const TimeUntilNextGameWidget(),
              const PreviousWeekWinnerCalloutWidget(),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    child: SingleChildScrollView(
                      child: Column(
                        children: const [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("Today's results", style: TextStyle(fontSize: 20)),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: HistoryDataTable(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
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
    final alreadyPlayed = Provider.of<Submissions>(context).alreadyPlayed;
    final canPlay = hasName && !alreadyPlayed;
    return FloatingActionButton(
      heroTag: "play",
      backgroundColor: canPlay ? null : Colors.grey,
      onPressed: () => canPlay
          ? Navigator.of(context).push(MaterialPageRoute(
              builder: (_) =>
                  GameWidget(game: Game(dict, dict.todaysWord, dict.todaysAnswer, true))))
          : ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(alreadyPlayed ? "Already played today" : "Must set name"))),
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

class HistoryButton extends StatelessWidget {
  const HistoryButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      heroTag: "history",
      onPressed: () => pushHistory(context),
      child: const Icon(Icons.leaderboard),
    );
  }
}

class ChatButton extends StatelessWidget {
  const ChatButton({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
        stream: FirebaseAuth.instance
            .authStateChanges()
            .switchMap((user) => FirebaseFirestore.instance
                .collection('users')
                .doc(user?.uid ?? "")
                .snapshots()
                .map((event) => event.data()?['chatLastVisited'] ?? '2018-01-01'))
            .switchMap((date) => FirebaseFirestore.instance
                .collection('chats')
                .orderBy('date', descending: true)
                .limit(1)
                .snapshots()
                .map((event) =>
                    (event.docs.firstOrNull?.data()['date'] ?? '').toString().compareTo(date) > 0)),
        builder: (context, snapshot) => FloatingActionButton(
              heroTag: "chat",
              onPressed: () => pushChat(context),
              backgroundColor: snapshot.data ?? false ? Colors.green : null,
              child: const Icon(Icons.message),
            ));
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
      builder: (_) => GameWidget(game: Game(dict, dict.randomWord, dict.randomAnswer, false))));
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
          SizedBox(height: 16),
          UndoButton(),
          PracticeButton(),
          SizedBox(height: 16),
          HistoryButton(),
        ],
      );
    }
    return const SizedBox();
  }
}

class BurkhardFilter with ChangeNotifier {
  bool active = false;
  void setActive(bool active) {
    this.active = active;
    notifyListeners();
  }
}

final burk = BurkhardFilter();

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
      return ListView(
          children: ListTile.divideTiles(context: context, tiles: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Reidle",
              style: GoogleFonts.roboto(fontSize: 30),
            ),
          ),
        ),
        ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Home"),
            onTap: () => Navigator.of(context).popUntil((route) => route.isFirst)),
        ListTile(
            leading: const Icon(Icons.leaderboard),
            title: const Text('Board'),
            onTap: () {
              Navigator.of(context).pop();
              pushHistory(context);
            }),
        ListTile(
            leading: const Icon(Icons.timer),
            title: const Text('Practice'),
            onTap: () {
              Navigator.of(context).pop();
              pushPractice(context);
            }),
        ListTile(
            leading: const Icon(Icons.message),
            title: const Text('Chat'),
            onTap: () {
              Navigator.of(context).pop();
              pushChat(context);
            }),
        ListTile(
          leading: const Icon(Icons.notification_add),
          title: const Text('Notifications'),
          onTap: () => launchUrl(Uri.parse("https://groups.google.com/g/reidle")),
        ),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('Rules'),
          onTap: () => launchUrl(Uri.parse("https://shorturl.at/ltEHX")),
        ),
        CheckboxListTile(
          title: Row(children: const [Icon(Icons.woman), Text("Burkhard Filter")]),
          onChanged: (value) => context.read<BurkhardFilter>().setActive(value ?? false),
          value: context.watch<BurkhardFilter>().active,
        )
      ]).toList());
    }));
  }
}

void pushHistory(BuildContext context) =>
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const HistoryPage()));
void pushChat(BuildContext context) =>
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChatWidget()));

class PlaybackPage extends StatelessWidget {
  final Submission? submission;
  const PlaybackPage({this.submission, super.key});

  @override
  Widget build(BuildContext context) {
    final submission =
        this.submission ?? Provider.of<Submissions>(context).currentWinner?.submission;
    return Scaffold(
        appBar: AppBar(
          title: const Text("Playback"),
        ),
        drawer: const ReidleDrawer(),
        body: Center(
          child: submission?.events?.isEmpty ?? true
              ? const Text("loading")
              : PlaybackWidget(submission!),
        ));
  }
}

class HistoryPage extends StatelessWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
            title: const Text("Board"),
            actions: const [HomeButton()],
            bottom: TabBar(
                tabs: ["This Week", "Today", "History"]
                    .map((x) => Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(x),
                        ))
                    .toList())),
        drawer: const ReidleDrawer(),
        body: TabBarView(
            children: const [
          ThisWeekDataTable(),
          HistoryDataTable(),
          PreviousDataTable(),
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

void submissionSnackbar(BuildContext context, Submission submission, [String? todaysAnswer]) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text([submission.error ?? 'Win', todaysAnswer].where((x) => x != null).join(': '))));
}

enum PlaybackStatus { normal, penalty, done }

extension on PlaybackStatus {
  Color get color =>
      {
        PlaybackStatus.normal: Colors.white,
        PlaybackStatus.penalty: Colors.red.shade300,
        PlaybackStatus.done: Colors.green.shade100,
      }[this] ??
      Colors.white;
}

class PlaybackState {
  final List<String> guesses;
  final PlaybackStatus status;

  Color get color => status.color;

  PlaybackState(List<String> guesses, this.status) : guesses = List.from(guesses);

  factory PlaybackState.initial(Submission submission) => PlaybackState(
      [submission.guesses?.firstOrNull ?? dict.wordForDate(submission.submissionTime), ""],
      PlaybackStatus.normal);
}

Stream<PlaybackState> playbackStream(Submission submission) async* {
  const maxSleepValue = Duration(milliseconds: 300);
  Future<dynamic> maxSleep(Duration duration) =>
      Future.delayed(duration < maxSleepValue ? duration : maxSleepValue);
  final guesses = PlaybackState.initial(submission).guesses.toList();
  for (final event in submission.events ?? []) {
    await maxSleep(event.duration);
    yield* event.event.whenOrNull(
          word: (w) async* {
            if (w == guesses.last) {
              return;
            }
            yield PlaybackState(
                guesses
                  ..removeLast()
                  ..add(w),
                PlaybackStatus.normal);
          },
          penalty: (duration) async* {
            yield PlaybackState(guesses, PlaybackStatus.penalty);
            await maxSleep(duration);
          },
          enter: () async* {
            yield PlaybackState(guesses..add(""), PlaybackStatus.normal);
          },
        ) ??
        const Stream.empty();
  }
}

class PlaybackWidget extends StatelessWidget {
  final Submission submission;
  const PlaybackWidget(this.submission, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => StreamProvider<PlaybackState>(
        create: (context) => playbackStream(submission),
        initialData: PlaybackState.initial(submission),
        builder: (context, _) {
          final state = Provider.of<PlaybackState>(context);
          final answer = submission.answer ?? dict.answerForDate(submission.submissionTime);
          return Card(
              color: scoreWordle(answer, state.guesses).won ? Colors.green.shade200 : state.color,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: WordleWidget(answer, state.guesses),
              ));
        },
      );
}

class ThisWeekDataTable extends StatelessWidget {
  const ThisWeekDataTable({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final days = DateTime.now().toUtc().weekday;
    final submissions = Provider.of<Submissions>(context);
    final week =
        submissions.weekCache.cache.putIfAbsent(DateTime.now().toUtc().reidleWeek, () => {});
    final players = week[0]?.entries.sorted((t) => CompareList([
              t.value,
              submissions.weekCache.secondsCache
                  .putIfAbsent(DateTime.now().toUtc().reidleWeek, () => {})
                  .putIfAbsent(0, () => {})
                  .putIfAbsent(t.key, () => 2)
            ])) ??
        [];
    final burk = context.watch<BurkhardFilter>().active;
    return DataTable(
        columnSpacing: 0,
        horizontalMargin: 10,
        columns: [
          const DataColumn(label: Text("Name")),
          const DataColumn(label: Text("Π")),
          ..."MTWRFSU".characters.take(days).map((e) => DataColumn(label: Text(e), numeric: true)),
        ],
        rows: players
            .where((s) => !burk || !{'tracy', 'natnat'}.contains(s.key.toLowerCase()))
            .map(
              (t) => DataRow(cells: [
                DataCell(Text(t.key.substring(0, t.key.length.min(10)))),
                DataCell(Text(t.value.toString())),
                ...1.to(days + 1).map((x) => (week[x]?[t.key] ?? 5)).map((x) => DataCell(Text(
                      x.toString(),
                      style: TextStyle(
                        color: x.color,
                        fontWeight: FontWeight.bold,
                      ),
                    )))
              ], color: t.key.isMyName ? MaterialStateProperty.all(Colors.yellow.shade200) : null),
            )
            .toList());
  }
}

extension on int {
  Color get color =>
      {
        1: Colors.green[800],
        2: Colors.green[700],
        3: Colors.yellow[800],
        4: Colors.deepOrange,
        5: Colors.red[900]
      }[this] ??
      Colors.black;
}

class PreviousDataTable extends StatelessWidget {
  const PreviousDataTable({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final weekCache = Provider.of<Submissions>(context).weekCache;
    final burk = context.watch<BurkhardFilter>().active;
    return DataTable(
        columns: [
          'week',
          'name',
          'score',
        ].map((s) => DataColumn(label: Text(s))).toList(),
        rows: weekCache.winners
            .where((s) => !burk || !{'tracy', 'natnat'}.contains(s.value.toLowerCase()))
            .map((e) => DataRow(
                color: e.value.isMyName ? MaterialStateProperty.all(Colors.yellow.shade200) : null,
                cells: [e.key, e.value, weekCache.cache[e.key]?[0]?[e.value]]
                    .map((x) => DataCell(Text(x.toString())))
                    .toList()))
            .toList());
  }
}

class HistoryDataTable extends StatelessWidget {
  bool get frontPage => true;
  const HistoryDataTable({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<Submissions>(context);
    final burk = context.watch<BurkhardFilter>().active;
    return DataTable(
        columnSpacing: 20,
        columns: [
          'paste',
          'name',
          if (!frontPage) 'date',
          'time',
          'pen',
          'watch',
        ].map((s) => DataColumn(label: Text(s))).toList(),
        rows: provider.submissions
            .take(30)
            .where((s) => !burk || !{'tracy', 'natnat'}.contains(s.submission.name.toLowerCase()))
            .where((s) => s.submission.submissionTime.isAfter(frontPage
                ? DateTime.now().startOfDay
                : DateTime.now().subtract(const Duration(days: 40))))
            .sorted((t) => frontPage
                ? t.submission.time as Comparable
                : -t.submission.submissionTime.millisecondsSinceEpoch)
            .map((e) => DataRow(
                  onLongPress: e.submission.error?.isNotEmpty ?? false
                      ? () => submissionSnackbar(context, e.submission)
                      : null,
                  color: MaterialStateProperty.all(e.isWinner
                      ? Colors.green.shade100
                      : !e.submission.won
                          ? Colors.red.shade100
                          : e.isMe
                              ? Colors.yellow.shade100
                              : Colors.white),
                  cells: [
                    DataCell(Text(
                      (!provider.alreadyPlayed && e.submission.submissionTime.isToday)
                          ? ""
                          : e.submission.paste ?? "",
                      style: const TextStyle(fontSize: 6),
                    )),
                    DataCell(
                        Text(e.submission.name.substring(0, min(e.submission.name.length, 7)))),
                    if (!frontPage)
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
                    DataCell(
                        e.submission.events?.isEmpty ?? true
                            ? Container()
                            : Icon(
                                Icons.play_arrow,
                                color:
                                    (!provider.alreadyPlayed && e.submission.submissionTime.isToday)
                                        ? Colors.grey
                                        : null,
                              ),
                        onTap: (e.submission.events?.isEmpty ?? true) ||
                                (!provider.alreadyPlayed && e.submission.submissionTime.isToday)
                            ? null
                            : () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PlaybackPage(submission: e.submission)))),
                  ],
                ))
            .toList());
  }
}

class PreviousWeekWinnerCalloutWidget extends StatelessWidget {
  const PreviousWeekWinnerCalloutWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final thisWeeksWinnersName = context.watch<BurkhardFilter>().active
        ? {"Michael Jordan", "Lady Gaga", "Wiz Khalifa", "Sakis", "Jon Bon Jovi", "Uncle Jesse"}
            .sample!
        : Provider.of<Submissions>(context)
                .weekCache
                .winners
                .find((value) => value.key == DateTime.now().toUtc().reidleWeek - 1)
                ?.value ??
            "None";
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("🏆 Current Champion: ", style: TextStyle(fontSize: 16)),
            Text(thisWeeksWinnersName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),
      )),
    );
  }
}

class TimeUntilNextGameWidget extends StatelessWidget {
  const TimeUntilNextGameWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Stream.periodic(const Duration(seconds: 1)),
        builder: (context, snapshot) {
          final now = DateTime.now().toUtc();
          final tomorrow = DateTime.now().toUtc().startOfDay.add(const Duration(days: 1));
          final durationUntilNextGame = tomorrow.difference(now);
          final hours = durationUntilNextGame.inHours;
          final minutes = durationUntilNextGame.inMinutes % 60;
          final seconds = durationUntilNextGame.inSeconds % 60;
          final timer =
              [hours, minutes, seconds].map((i) => i.toString().padLeft(2, '0')).join(':');
          return Text("Time until next game: $timer");
        });
  }
}
