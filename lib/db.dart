import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
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
      };
}

Map<String, dynamic> _patch(Map<String, dynamic> json) {
  return {
    ...json,
    'event': json['event']?.toJson(),
  };
}

extension UserName on User {
  String get name {
    final name = displayName ?? email ?? uid;
    if (name.length > 10) {
      return name.substring(0, 10);
    }
    return name;
  }
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
      .map((x) => Submissions(x.docs
          .map((y) => StreamSubmission(
              y.data(),
              y.data().won &&
                  x.docs
                      .where((x) =>
                          x.data().won &&
                          x.data().submissionTime.dateHash == y.data().submissionTime.dateHash)
                      .every((element) => element.data().time >= y.data().time)))
          .toList()));
}

class Submissions {
  final List<StreamSubmission> submissions;
  Submissions(this.submissions);

  StreamSubmission? get currentWinner =>
      submissions.where((s) => s.isWinner).where((s) => s.isToday).firstOrNull;

  List<RecorderEvent>? get playback => currentWinner?.submission.events;

  List<MapEntry<String, int>> get leaderboard => submissions
      .where((s) => s.isWinner)
      .groupBy((t) => t.submission.name.toLowerCase().trim().replaceAll(' ', ''))
      .map((e) => MapEntry(e.key, e.value.length))
      .toList()
    ..sort((a, b) => a.value > b.value ? -1 : 1);

  Duration? get bestTime => currentWinner?.submission.time;
}

class StreamSubmission {
  final Submission submission;
  final bool isWinner;

  StreamSubmission(this.submission, this.isWinner);

  bool get isToday => submission.submissionTime.isToday;
}

final db = _Db();

extension _D on DateTime {
  bool get isToday => DateTime.now().toUtc().dateHash == toUtc().dateHash;
  int get dateHash => [year, month, day].join('').hashCode;
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;

  Iterable<MapEntry<K, List<T>>> groupBy<K>(K Function(T t) grouper) {
    final map = <K, List<T>>{};
    for (final t in this) {
      final key = grouper(t);
      if (!map.containsKey(key)) {
        map[key] = [];
      }
      map[key]?.add(t);
    }
    return map.entries;
  }
}
