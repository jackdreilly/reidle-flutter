import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Submission {
  final String name;
  final Duration time;
  final DateTime submissionTime;
  final String? error;
  final String? paste;

  bool get won {
    return (error?.length ?? 0) == 0 && (paste?.trimRight().endsWith("🟩🟩🟩🟩🟩") ?? false);
  }

  Submission({
    required this.name,
    required this.time,
    required this.submissionTime,
    this.error,
    this.paste,
  });

  factory Submission.fromFirestore(Map<String, dynamic> json) => Submission(
        name: json['name'] as String,
        time: Duration(microseconds: json['time'] as int),
        submissionTime: DateTime.parse(json['submissionTime'] as String),
        error: json['error'] as String?,
        paste: json['paste'] as String?,
      );

  Map<String, dynamic> get toFirestore => {
        'name': name,
        'time': time.inMicroseconds,
        'submissionTime': submissionTime.toIso8601String(),
        'error': error,
        'paste': paste,
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
  FirebaseFirestore get firestore => FirebaseFirestore.instance;
  MapEntry<Future<DocumentReference<Submission>>, Submission> add(
      User user, Duration time, String paste, String? error) {
    final submission = Submission(
        name: user.name,
        time: time,
        submissionTime: DateTime.now().toUtc(),
        paste: paste,
        error: error);
    return MapEntry(collection.add(submission), submission);
  }

  Stream<Submissions> get submissions => collection
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

  CollectionReference<Submission> get collection =>
      firestore.collection('submissions').withConverter<Submission>(
          fromFirestore: (x, _) => Submission.fromFirestore(x.data() ?? {}),
          toFirestore: (x, _) => x.toFirestore);
}

class Submissions {
  final List<StreamSubmission> submissions;
  Submissions(this.submissions);

  List<MapEntry<String, int>> get leaderboard => submissions
      .where((s) => s.isWinner)
      .groupBy((t) => t.submission.name.toLowerCase().trim().replaceAll(' ', ''))
      .map((e) => MapEntry(e.key, e.value.length))
      .toList()
    ..sort((a, b) => a.value > b.value ? -1 : 1);
}

class StreamSubmission {
  final Submission submission;
  final bool isWinner;

  StreamSubmission(this.submission, this.isWinner);
}

final db = _Db();

extension _D on DateTime {
  int get dateHash => [year, month, day].join('').hashCode;
}

extension<T> on Iterable<T> {
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
