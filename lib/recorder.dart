import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
part 'recorder.freezed.dart';

@freezed
class Event with _$Event {
  const factory Event.letter(String key) = Letter;
  const factory Event.backspace() = Backspace;
  const factory Event.enter() = Enter;
  const factory Event.penalty(Duration duration) = Penalty;
}

@freezed
class RecorderEvent with _$RecorderEvent {
  const factory RecorderEvent({
    required Duration duration,
    required Event event,
  }) = _RecorderEvent;
}

class Recorder {
  DateTime last = DateTime.now();
  final List<RecorderEvent> events = [];

  Recorder add(Event event) {
    final now = DateTime.now();
    final duration = now.difference(last);
    last = now;
    events.add(RecorderEvent(duration: duration, event: event));
    return this;
  }

  void start() {
    events.clear();
    last = DateTime.now();
  }
}
