// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:reidle/wordle.dart';

void main() {
  test('known failures', () async {
    expect(
        checkWordle("motif", scoreWordle("motif", ["altho", 'potty', 'totem']))
            .error,
        '"t" is present at most 1 time');
  });
  test(
      'apply',
      () => expect(
          checkWordle(
              "amply", scoreWordle("amply", ["spoor", "plank", 'apply'])).error,
          '"p" is not in position 2'));
}
