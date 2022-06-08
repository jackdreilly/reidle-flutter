import 'dart:math';

import 'package:flutter/services.dart';

extension _D on DateTime {
  int get dateHash => [year, month, day].join('').hashCode;
}

class Dictionary {
  late final Set<String> wordsSet;
  late final List<String> words;
  late final List<String> answers;
  Dictionary(String words, String answers) {
    this.words = words.split('\n');
    wordsSet = this.words.toSet();
    this.answers = answers.split('\n');
  }
  String get randomWord => words.sample!;
  String get randomAnswer => answers.sample!;

  bool isValid(String word) => wordsSet.contains(word);
  String answerForDate(DateTime submissionTime) => answers.grab(submissionTime);
  String wordForDate(DateTime submissionTime) => words.grab(submissionTime);
  String get todaysAnswer => answerForDate(DateTime.now());
  String get todaysWord => words.grab(DateTime.now());
}

Future<Dictionary> get dictionary async => Dictionary(
    await rootBundle.loadString('assets/words.csv'),
    await rootBundle.loadString('assets/answers.csv'));

extension<T> on List<T> {
  T? get sample => isEmpty ? null : this[Random().nextInt(length)];
  T grab(DateTime date) {
    if (date.isBefore(DateTime(2022, 6, 8))) {
      return this[(date.dateHash % ((length - 1) * 6)) ~/ 36];
    }
    return this[date.dateHash % length];
  }
}
