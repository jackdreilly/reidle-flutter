import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:reidle/extensions.dart';
import 'package:reidle/recorder.dart';

class Submission {
  final String name;
  final Duration time;
  final DateTime submissionTime;
  final String? error;
  final String? paste;
  final Duration? penalty;
  final String? uid;
  final List<RecorderEvent>? events;
  final String? answer;
  final List<String>? guesses;

  bool get won {
    return (error?.length ?? 0) == 0 && (paste?.trimRight().endsWith("🟩🟩🟩🟩🟩") ?? false);
  }

  Submission({
    required this.name,
    required this.time,
    required this.submissionTime,
    this.error,
    this.paste,
    this.penalty,
    this.uid,
    this.events,
    this.answer,
    this.guesses,
  });

  factory Submission.fromFirestore(Map<String, dynamic> json) => Submission(
        name: json['name'] as String,
        time: Duration(microseconds: json['time'] as int),
        penalty: Duration(microseconds: (json['penalty'] ?? 0) as int),
        submissionTime: DateTime.parse(json['submissionTime'] as String),
        error: json['error'] as String?,
        paste: json['paste'] as String?,
        uid: json['uid'] as String?,
        events: (json['events'] as List<dynamic>?)
            ?.map((e) => RecorderEvent.fromJson(e as Map<String, dynamic>))
            .toList(),
        answer: json['answer'] as String?,
        guesses: json.containsKey('guesses') ? List<String>.from(json['guesses']) : null,
      );

  Map<String, dynamic> get toFirestore => {
        'name': name,
        'time': time.inMicroseconds,
        'submissionTime': submissionTime.toIso8601String(),
        'error': error,
        'paste': paste,
        'penalty': penalty?.inMicroseconds ?? 0,
        'uid': uid,
        'events': events?.map((e) => _patch(e.toJson())).toList(),
        'answer': answer,
        'guesses': guesses,
      };
}

Map<String, dynamic> _patch(Map<String, dynamic> json) {
  return {
    ...json,
    'event': json['event']?.toJson(),
  };
}

class _Db {
  static final firestore = FirebaseFirestore.instance;
  static final collection = firestore
      .collection(kDebugMode ? 'submissions-test' : 'submissions')
      .withConverter<Submission>(
          fromFirestore: (x, _) => Submission.fromFirestore(x.data() ?? {}),
          toFirestore: (x, _) => x.toFirestore);

  CollectionReference<Submission> get submissions => collection;

  final submissionsStream = collection
      .orderBy('submissionTime', descending: true)
      .where('submissionTime',
          isGreaterThan:
              DateTime.now().toUtc().subtract(const Duration(days: 30)).toIso8601String())
      .snapshots()
      .map((d) => Submissions.make(d.docs))
      .asBroadcastStream();
}

class WeekCache {
  final Map<int, Map<int, Map<String, int>>> cache = {};
  final List<MapEntry<int, String>> winners = [];

  WeekCache(List<StreamSubmission> submissions) {
    for (final submission in submissions) {
      final submissionTime = submission.submission.submissionTime.toUtc();
      final week = submissionTime.reidleWeek;
      final day = submissionTime.weekday;
      final name = submission.submission.name;
      final score = submission.score.min(4);
      cache.putIfAbsent(week, () => {}).putIfAbsent(day, () => {})[name] = score;
    }
    for (final weekEntry in cache.entries) {
      final weekCache = weekEntry.value.putIfAbsent(0, () => {});
      for (final name in weekEntry.value.values.expand((e) => e.keys).toSet()) {
        weekCache[name] = 1;
        for (final day in 1.to(8)) {
          if (DateTime.now().toUtc().reidleWeek == weekEntry.key &&
              day > DateTime.now().toUtc().weekday) {
            continue;
          }
          weekCache[name] = (weekCache[name] ?? 1) *
              weekEntry.value.putIfAbsent(day, () => {}).putIfAbsent(name, () => 5);
        }
      }
    }
    winners.addAll(cache.entries
        .map((e) => MapEntry(e.key, e.value[0]?.entries.minBy((k) => k.value)?.key ?? ""))
        .where((element) => element.key < DateTime.now().toUtc().reidleWeek)
        .sorted((t) => -t.key));
  }
}

class Submissions {
  final List<StreamSubmission> submissions;
  final WeekCache weekCache;
  Submissions(this.submissions) : weekCache = WeekCache(submissions);

  StreamSubmission? get currentWinner =>
      submissions.where((s) => s.isWinner).where((s) => s.isToday).firstOrNull;

  List<RecorderEvent>? get playback => currentWinner?.submission.events;

  List<PreviousRecord> get previous => submissions
          .where((s) => s.isWinner)
          .where((s) => s.submission.submissionTime.reidleWeek != DateTime.now().reidleWeek)
          .where((s) =>
              s.submission.submissionTime.reidleWeek !=
              submissions.map((e) => e.submission.submissionTime.reidleWeek).maxBy((p0) => -p0))
          .groupBy((t) => t.submission.submissionTime.reidleWeek)
          .map((weekPair) {
        final winner = weekPair.value
            .groupBy((t) => t.submission.name.toLowerCase().trim().replaceAll(' ', ''))
            .map((x) => MapEntry(x.key, <Comparable>[
                  x.value.length,
                  -1 * x.value.sum((x) => x.submission.time.inMicroseconds),
                ]))
            .maxBy((x) => CompareList(x.value))!;
        return PreviousRecord(weekPair.key, winner.key, winner.value[0] as int,
            Duration(microseconds: (-1 * (winner.value[1] as num)).toInt()));
      }).toList()
        ..sort(((a, b) => b.week.compareTo(a.week)));

  List<MapEntry<String, MapEntry<int, num>>> get thisWeek => submissions
      .where((s) => s.isWinner)
      .where((s) => s.submission.submissionTime.reidleWeek == DateTime.now().reidleWeek)
      .groupBy((t) => t.submission.name.toLowerCase().trim().replaceAll(' ', ''))
      .map((e) => MapEntry(
          e.key, MapEntry(e.value.length, e.value.sum((p0) => p0.submission.time.inMicroseconds))))
      .toList()
    ..sort((a, b) {
      final x = [a, b].map((x) => CompareList([-x.value.key, x.value.value])).toList();
      return x.first.compareTo(x.last);
    });

  Duration? get bestTime => currentWinner?.submission.time;

  bool get alreadyPlayed => submissions.any((element) => element.isMe && element.isToday);

  factory Submissions.make(List<QueryDocumentSnapshot<Submission>> docs) => Submissions(docs
      .groupBy((t) => t.data().submissionTime.dateHash)
      .map((e) => e.value)
      .expand((element) => element
          .sorted((a) =>
              CompareList([a.data().won ? 0 : 1, a.data().time, a.data().guesses?.length ?? 6]))
          .enumerate
          .map((e) => StreamSubmission(e.value.data(), (e.key + 1))))
      .toList());
}

class PreviousRecord {
  final int week;
  final String name;
  final int wins;
  final Duration duration;

  PreviousRecord(this.week, this.name, this.wins, this.duration);
}

class StreamSubmission {
  final Submission submission;
  final int score;

  bool get isWinner => score == 1;

  StreamSubmission(this.submission, this.score);

  bool get isToday => submission.submissionTime.isToday;

  bool get isMe =>
      (submission.uid == FirebaseAuth.instance.currentUser?.uid || submission.name.isMyName) &&
      (submission.uid?.isNotEmpty ?? false);

  bool get isThisWeek => submission.submissionTime.isThisWeek;
}

final db = _Db();

class CompareList implements Comparable<CompareList> {
  final List<Comparable> list;
  CompareList(this.list);

  @override
  int compareTo(CompareList other) {
    for (final x in list.zip(other.list)) {
      final c = x.key.compareTo(x.value);
      if (c != 0) {
        return c;
      }
    }
    return 0;
  }
}
