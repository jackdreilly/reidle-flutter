import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reidle/extensions.dart';

enum Class { unused, miss, off, right }

extension ClassExtension on Class {
  Color get color =>
      {
        Class.unused: Colors.white,
        Class.miss: Colors.grey.shade400,
        Class.off: Colors.orange.shade400,
        Class.right: Colors.green.shade400,
      }[this] ??
      Colors.white;
}

class ClassLetter {
  final Class cls;
  final String letter;
  const ClassLetter(this.cls, this.letter);

  String get paste =>
      {
        Class.miss: '⬜',
        Class.unused: '⬜',
        Class.off: '🟨',
        Class.right: '🟩',
      }[cls] ??
      '⬜';

  @override
  String toString() => '$cls:$letter';
}

typedef ClassWord = List<ClassLetter>;

typedef ClassWords = List<ClassWord>;

extension ClassWordsExtension on ClassWords {
  String get paste => map((w) => w.map((l) => l.paste).join()).join('\n');
}

ClassWords scoreWordle(String word, List<String> guesses) => guesses
    .map((e) {
      if (e.length > 5) {
        return e.substring(0, 5);
      }
      return e.padRight(5, " ");
    })
    .toList()
    .map((g) => _score(word, g))
    .toList();

extension X on ClassWords {
  bool get won => isEmpty ? false : last.every((element) => element.cls == Class.right);
}

ClassWord _score(String word, String guess) {
  final used = <int>{};
  final ClassWord output = [];
  for (var i = 0; i < guess.length; i++) {
    var result = Class.miss;
    var position = -1;
    final guessLetter = guess[i];
    if (word[i] == guessLetter) {
      result = Class.right;
    } else {
      for (var j = 0; j < word.length; j++) {
        if (word[j] == guess[j] || used.contains(j)) continue;
        if (word[j] == guessLetter) {
          result = Class.off;
          position = j;
          break;
        }
      }
    }
    used.add(position);
    output.add(ClassLetter(result, guessLetter));
  }
  return output;
}

class WordleWidget extends StatelessWidget {
  final String word;

  final List<String> guesses;

  const WordleWidget(this.word, this.guesses, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(children: scoreWordle(word, guesses).map(ClassWordWidget.fromClassWord).toList());
  }
}

class ClassWordWidget extends StatelessWidget {
  final ClassWord word;
  const ClassWordWidget(this.word, {Key? key}) : super(key: key);
  factory ClassWordWidget.fromClassWord(ClassWord word, {Key? key}) =>
      ClassWordWidget(word, key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: word.map(ClassLetterWidget.make).toList());
  }
}

class ClassLetterWidget extends StatelessWidget {
  final ClassLetter letter;
  const ClassLetterWidget(this.letter, {Key? key}) : super(key: key);

  factory ClassLetterWidget.make(ClassLetter letter) => ClassLetterWidget(letter);

  @override
  Widget build(BuildContext context) {
    final letterSize = min(40.0, MediaQuery.of(context).size.width / 12.0);
    return Padding(
      padding: const EdgeInsets.all(2),
      child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black54, width: 1),
            borderRadius: BorderRadius.circular(2),
            color: letter.cls.color,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: letter.letter == '↵'
                ? Icon(Icons.check, size: letterSize * 0.7)
                : letter.letter == '␡'
                    ? Icon(Icons.backspace, size: letterSize * 0.7)
                    : Text(
                        letter.letter,
                        style: GoogleFonts.robotoMono(fontSize: letterSize),
                        textAlign: TextAlign.center,
                      ),
          )),
    );
  }
}

class WordleKeyboardWidget extends StatelessWidget {
  final String word;

  final List<String> guesses;
  final void Function(String k) onPressed;

  const WordleKeyboardWidget(this.word, this.guesses, {Key? key, required this.onPressed})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    final result = scoreWordle(word, guesses);
    final lookup = {};
    for (var element in result) {
      for (var letter in element) {
        if (letter.cls.index > (lookup[letter.letter] ?? Class.unused).index) {
          lookup[letter.letter] = letter.cls;
        }
      }
    }
    return Column(
        children: 'qwertyuiop,asdfghjkl,↵zxcvbnm␡'
            .split(',')
            .map((e) => ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: e
                          .split('')
                          .map((e) => Expanded(
                                child: InkWell(
                                    onTap: () => onPressed(e),
                                    child: ClassLetterWidget(
                                        ClassLetter(lookup[e] ?? Class.unused, e))),
                              ))
                          .toList()),
                ))
            .toList());
  }
}

class Checked {
  final bool finished;
  final String? error;

  const Checked(this.finished, this.error);
}

Checked checkWordle(String word, ClassWords guesses) {
  if (guesses.last.every((l) => l.cls == Class.right)) {
    return const Checked(true, null);
  }
  if (guesses.length >= 6) {
    return const Checked(true, 'Too many guesses');
  }
  Set<String> misses = {};
  Set<String> offs = {};
  Set<int> ons = {};
  Map<String, int> minRights = {};
  final maxRights = <String, int>{};
  int rights = 0;
  for (var guess in guesses) {
    final newRights = guess.where((l) => l.cls != Class.miss).length;
    if (newRights < rights) {
      return Checked(false, 'Right count decreased ($rights -> $newRights)');
    }
    rights = newRights;
    for (int iLetter = 0; iLetter < guess.length; iLetter++) {
      final letter = guess[iLetter];
      if (ons.contains(iLetter) && letter.cls != Class.right) {
        return Checked(false, 'Correct "${word[iLetter]}" was dropped (position ${iLetter + 1})');
      }
      if (letter.cls == Class.right) {
        ons.add(iLetter);
      }
      if (letter.cls == Class.miss) {
        if (misses.contains(letter.letter)) {
          return Checked(false, '"${letter.letter}" is not in word');
        }
      }
      if (letter.cls == Class.off || letter.cls == Class.miss) {
        final hash = [letter.letter, iLetter].join('');
        if (offs.contains(hash)) {
          return Checked(false, '"${letter.letter}" is not in position ${iLetter + 1}');
        }
        offs.add(hash);
      }
    }
    for (var off in minRights.entries) {
      final letter = off.key;
      final count = off.value;
      final present = guess.where((g) => g.letter == letter).length;
      if (present < count) {
        return Checked(false, '"$letter" is present at least $count time${count > 1 ? 's' : ''}');
      }
    }
    misses.addAll(guess.map((e) => e.letter).where((l) => !word.contains(l)));
    minRights = Map.fromEntries(guess
        .where((element) => element.cls != Class.miss)
        .groupBy((t) => t.letter)
        .map((e) => MapEntry(e.key, e.value.length)));
    for (var element in guess.groupBy((t) => t.letter)) {
      if (element.value.length > (maxRights[element.key] ?? 7)) {
        final count = maxRights[element.key] ?? 7;
        return Checked(
            false, '"${element.key}" is present at most $count time${count > 1 ? 's' : ''}');
      }
      if (element.value.any((element) => element.cls == Class.miss)) {
        maxRights[element.key] =
            element.value.where((x) => [Class.right, Class.off].contains(x.cls)).length;
      }
    }
  }
  return const Checked(false, null);
}
