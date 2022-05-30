import 'package:flutter/services.dart';

extension _D on DateTime {
  int get dateHash => [year, month, day].join('').hashCode;
}

class Dictionary {
  final Set<String> words;
  final String todaysWord;
  final String todaysAnswer;

  bool isValid(String word) => words.contains(word);

  Dictionary(this.words, this.todaysWord, this.todaysAnswer);
}

Future<Dictionary> get dictionary async {
  final date = DateTime.now().toUtc();
  final words = await rootBundle.loadString('assets/words.csv');
  final answers = await rootBundle.loadString('assets/answers.csv');
  var iWord = (date.dateHash % words.length) ~/ 6;
  iWord -= (iWord % 6);
  var iAnswer = (date.dateHash % answers.length) ~/ 6;
  iAnswer -= (iAnswer % 6);
  return Dictionary(
      words.split('\n').toSet(),
      words.substring(iWord, iWord + 5),
      answers.substring(iAnswer, iAnswer + 5));
}
