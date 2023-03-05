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
  static const int defaultMinutes = 2;
  static const int daysPerWeek = 7;
  static final int maxPlaces = 4;
  final Map<int, Map<int, Map<String, int>>> cache = {};
  final Map<int, Map<int, Map<String, double>>> secondsCache = {};
  final List<MapEntry<int, String>> winners = [];

  WeekCache(List<StreamSubmission> submissions) {
    for (final submission in submissions) {
      final submissionTime = submission.submission.submissionTime.toUtc();
      final week = submissionTime.reidleWeek;
      final day = submissionTime.weekday;
      final name = submission.submission.name;
      final score = submission.score.min(4);
      cache.putIfAbsent(week, () => {}).putIfAbsent(day, () => {})[name] = score;
      secondsCache.putIfAbsent(week, () => {}).putIfAbsent(day, () => {})[name] =
          2.0.min(submission.submission.time.inMilliseconds.toDouble() / 60.0 / 1000.0);
    }
    for (final weekEntry in cache.entries) {
      final weekCache = weekEntry.value.putIfAbsent(0, () => {});
      final secondsWeekCache =
          secondsCache.putIfAbsent(weekEntry.key, () => {}).putIfAbsent(0, () => {});
      for (final name in weekEntry.value.values.expand((e) => e.keys).toSet()) {
        weekCache[name] = 1;
        secondsWeekCache[name] = 1;
        for (final day in 1.to(daysPerWeek + 1)) {
          final utc = DateTime.now().toUtc();
          if (utc.reidleWeek == weekEntry.key && day > utc.weekday) {
            continue;
          }
          weekCache[name] = (weekCache[name] ?? 1) *
              weekEntry.value.putIfAbsent(day, () => {}).putIfAbsent(name, () => forfeitPlace);
          secondsWeekCache[name] = (secondsWeekCache[name] ?? 1) *
              secondsCache
                  .putIfAbsent(weekEntry.key, () => {})
                  .putIfAbsent(day, () => {})
                  .putIfAbsent(name, () => defaultMinutes.toDouble());
        }
      }
    }
    winners.addAll(cache.entries
        .map((e) => MapEntry(
              e.key,
              e.value[0]?.entries
                      .minBy(
                        (k) => CompareList([
                          k.value,
                          secondsCache[e.key]?[0]?[k.key] ?? defaultMinutes * daysPerWeek,
                        ]),
                      )
                      ?.key ??
                  "",
            ))
        .where((element) => element.key < DateTime.now().toUtc().reidleWeek)
        .sorted((t) => -t.key));
  }

  static get forfeitPlace => maxPlaces + 1;
}

class Submissions {
  final List<StreamSubmission> submissions;
  final WeekCache weekCache;
  Submissions(this.submissions) : weekCache = WeekCache(submissions);

  StreamSubmission? get currentWinner =>
      submissions.where((s) => s.isWinner).where((s) => s.isToday).firstOrNull;

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
