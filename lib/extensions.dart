import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';

extension Stopwatch on Duration {
  String get stopwatchString =>
      '${inMinutes.toString().padLeft(2, '0')}:${(inSeconds % 60).toString().padLeft(2, '0')}';
}

extension IE<T> on Iterable<T> {
  T? minBy(Comparable Function(T value) test) {
    if (isEmpty) {
      return null;
    }
    var best = first;
    var value = test(best);
    for (final next in skip(1)) {
      final nextValue = test(next);
      if (nextValue.compareTo(value) < 0) {
        best = next;
        value = nextValue;
      }
    }
    return best;
  }

  T? find<S>(bool Function(T value) test) {
    for (final element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }

  Iterable<MapEntry<int, T>> get enumerate sync* {
    var i = 0;
    for (final x in this) {
      yield MapEntry(i++, x);
    }
  }

  T? get firstOrNull => isEmpty ? null : first;
  Iterable<T> separate<S extends T>(S w) sync* {
    if (isNotEmpty) yield first;
    for (final e in skip(1)) {
      yield w;
      yield e;
    }
  }

  List<T> sorted(Comparable Function(T t) key) =>
      toList()..sort((a, b) => key(a).compareTo(key(b)));
  num sum(num Function(T) f) => fold(0, (a, b) => a + f(b));
  T? maxBy(Comparable Function(T) key) =>
      isEmpty ? null : zip(map(key)).reduce((a, b) => a.value.compareTo(b.value) > 0 ? a : b).key;

  Iterable<MapEntry<T, S>> zip<S>(Iterable<S> other) sync* {
    final iterator = other.iterator;
    for (var e in this) {
      if (!iterator.moveNext()) {
        return;
      }
      yield MapEntry(e, iterator.current);
    }
  }

  Iterable<MapEntry<K, List<T>>> groupBy<K>(K Function(T t) grouper) {
    final map = <K, List<T>>{};
    for (final t in this) {
      map.putIfAbsent(grouper(t), () => []).add(t);
    }
    return map.entries;
  }
}

extension S on String {
  String get normalized => toLowerCase().trim().replaceAll(' ', '');
  bool get isMyName => normalized == FirebaseAuth.instance.currentUser?.name.normalized;
}

extension DTE on DateTime {
  int get dateHash => isUtc ? [year, month, day].join('').hashCode : toUtc().dateHash;
  DateTime get startOfDay {
    final base = toUtc();
    return DateTime.utc(base.year, base.month, base.day);
  }

  bool get isThisWeek => reidleWeek == DateTime.now().reidleWeek;
  bool get isToday => DateTime.now().toUtc().dateHash == toUtc().dateHash;
  String get dateString => isUtc ? '$month/$day' : toUtc().dateString;
  static final epoch = DateTime.utc(2022, 4, 4);
  int get reidleWeek => toUtc().difference(epoch).inDays ~/ 7;
  int get reidleDay => toUtc().difference(epoch).inDays % 7 + 1;
}

extension LE<T> on List<T> {
  T? get sample => isEmpty ? null : this[Random().nextInt(length)];
  T grab(DateTime date) {
    if (date.isBefore(DateTime(2022, 6, 8))) {
      return this[(date.dateHash % ((length - 1) * 6)) ~/ 36];
    }
    return this[date.dateHash % length];
  }
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

extension IntE on int {
  Iterable<int> to(int exclusiveEnd) sync* {
    for (var i = this; i < exclusiveEnd; i++) {
      yield i;
    }
  }
}

extension NumE<T extends num> on T {
  T max(T other) => this < other ? other : this;
  T min(T other) => this > other ? other : this;
}

extension Product<T extends num> on Iterable<T> {
  num get product {
    num result = 1;
    for (final v in this) {
      result *= v;
    }
    return result;
  }
}
