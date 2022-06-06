// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'recorder.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

Event _$EventFromJson(Map<String, dynamic> json) {
  switch (json['runtimeType']) {
    case 'word':
      return Word.fromJson(json);
    case 'enter':
      return Enter.fromJson(json);
    case 'penalty':
      return Penalty.fromJson(json);

    default:
      throw CheckedFromJsonException(json, 'runtimeType', 'Event',
          'Invalid union type "${json['runtimeType']}"!');
  }
}

/// @nodoc
mixin _$Event {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String word) word,
    required TResult Function() enter,
    required TResult Function(Duration duration) penalty,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(String word)? word,
    TResult Function()? enter,
    TResult Function(Duration duration)? penalty,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String word)? word,
    TResult Function()? enter,
    TResult Function(Duration duration)? penalty,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Word value) word,
    required TResult Function(Enter value) enter,
    required TResult Function(Penalty value) penalty,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(Word value)? word,
    TResult Function(Enter value)? enter,
    TResult Function(Penalty value)? penalty,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Word value)? word,
    TResult Function(Enter value)? enter,
    TResult Function(Penalty value)? penalty,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EventCopyWith<$Res> {
  factory $EventCopyWith(Event value, $Res Function(Event) then) =
      _$EventCopyWithImpl<$Res>;
}

/// @nodoc
class _$EventCopyWithImpl<$Res> implements $EventCopyWith<$Res> {
  _$EventCopyWithImpl(this._value, this._then);

  final Event _value;
  // ignore: unused_field
  final $Res Function(Event) _then;
}

/// @nodoc
abstract class _$$WordCopyWith<$Res> {
  factory _$$WordCopyWith(_$Word value, $Res Function(_$Word) then) =
      __$$WordCopyWithImpl<$Res>;
  $Res call({String word});
}

/// @nodoc
class __$$WordCopyWithImpl<$Res> extends _$EventCopyWithImpl<$Res>
    implements _$$WordCopyWith<$Res> {
  __$$WordCopyWithImpl(_$Word _value, $Res Function(_$Word) _then)
      : super(_value, (v) => _then(v as _$Word));

  @override
  _$Word get _value => super._value as _$Word;

  @override
  $Res call({
    Object? word = freezed,
  }) {
    return _then(_$Word(
      word == freezed
          ? _value.word
          : word // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$Word with DiagnosticableTreeMixin implements Word {
  const _$Word(this.word, {final String? $type}) : $type = $type ?? 'word';

  factory _$Word.fromJson(Map<String, dynamic> json) => _$$WordFromJson(json);

  @override
  final String word;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Event.word(word: $word)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Event.word'))
      ..add(DiagnosticsProperty('word', word));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$Word &&
            const DeepCollectionEquality().equals(other.word, word));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(word));

  @JsonKey(ignore: true)
  @override
  _$$WordCopyWith<_$Word> get copyWith =>
      __$$WordCopyWithImpl<_$Word>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String word) word,
    required TResult Function() enter,
    required TResult Function(Duration duration) penalty,
  }) {
    return word(this.word);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(String word)? word,
    TResult Function()? enter,
    TResult Function(Duration duration)? penalty,
  }) {
    return word?.call(this.word);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String word)? word,
    TResult Function()? enter,
    TResult Function(Duration duration)? penalty,
    required TResult orElse(),
  }) {
    if (word != null) {
      return word(this.word);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Word value) word,
    required TResult Function(Enter value) enter,
    required TResult Function(Penalty value) penalty,
  }) {
    return word(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(Word value)? word,
    TResult Function(Enter value)? enter,
    TResult Function(Penalty value)? penalty,
  }) {
    return word?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Word value)? word,
    TResult Function(Enter value)? enter,
    TResult Function(Penalty value)? penalty,
    required TResult orElse(),
  }) {
    if (word != null) {
      return word(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$WordToJson(this);
  }
}

abstract class Word implements Event {
  const factory Word(final String word) = _$Word;

  factory Word.fromJson(Map<String, dynamic> json) = _$Word.fromJson;

  String get word => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  _$$WordCopyWith<_$Word> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$EnterCopyWith<$Res> {
  factory _$$EnterCopyWith(_$Enter value, $Res Function(_$Enter) then) =
      __$$EnterCopyWithImpl<$Res>;
}

/// @nodoc
class __$$EnterCopyWithImpl<$Res> extends _$EventCopyWithImpl<$Res>
    implements _$$EnterCopyWith<$Res> {
  __$$EnterCopyWithImpl(_$Enter _value, $Res Function(_$Enter) _then)
      : super(_value, (v) => _then(v as _$Enter));

  @override
  _$Enter get _value => super._value as _$Enter;
}

/// @nodoc
@JsonSerializable()
class _$Enter with DiagnosticableTreeMixin implements Enter {
  const _$Enter({final String? $type}) : $type = $type ?? 'enter';

  factory _$Enter.fromJson(Map<String, dynamic> json) => _$$EnterFromJson(json);

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Event.enter()';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('type', 'Event.enter'));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$Enter);
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String word) word,
    required TResult Function() enter,
    required TResult Function(Duration duration) penalty,
  }) {
    return enter();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(String word)? word,
    TResult Function()? enter,
    TResult Function(Duration duration)? penalty,
  }) {
    return enter?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String word)? word,
    TResult Function()? enter,
    TResult Function(Duration duration)? penalty,
    required TResult orElse(),
  }) {
    if (enter != null) {
      return enter();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Word value) word,
    required TResult Function(Enter value) enter,
    required TResult Function(Penalty value) penalty,
  }) {
    return enter(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(Word value)? word,
    TResult Function(Enter value)? enter,
    TResult Function(Penalty value)? penalty,
  }) {
    return enter?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Word value)? word,
    TResult Function(Enter value)? enter,
    TResult Function(Penalty value)? penalty,
    required TResult orElse(),
  }) {
    if (enter != null) {
      return enter(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$EnterToJson(this);
  }
}

abstract class Enter implements Event {
  const factory Enter() = _$Enter;

  factory Enter.fromJson(Map<String, dynamic> json) = _$Enter.fromJson;
}

/// @nodoc
abstract class _$$PenaltyCopyWith<$Res> {
  factory _$$PenaltyCopyWith(_$Penalty value, $Res Function(_$Penalty) then) =
      __$$PenaltyCopyWithImpl<$Res>;
  $Res call({Duration duration});
}

/// @nodoc
class __$$PenaltyCopyWithImpl<$Res> extends _$EventCopyWithImpl<$Res>
    implements _$$PenaltyCopyWith<$Res> {
  __$$PenaltyCopyWithImpl(_$Penalty _value, $Res Function(_$Penalty) _then)
      : super(_value, (v) => _then(v as _$Penalty));

  @override
  _$Penalty get _value => super._value as _$Penalty;

  @override
  $Res call({
    Object? duration = freezed,
  }) {
    return _then(_$Penalty(
      duration == freezed
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as Duration,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$Penalty with DiagnosticableTreeMixin implements Penalty {
  const _$Penalty(this.duration, {final String? $type})
      : $type = $type ?? 'penalty';

  factory _$Penalty.fromJson(Map<String, dynamic> json) =>
      _$$PenaltyFromJson(json);

  @override
  final Duration duration;

  @JsonKey(name: 'runtimeType')
  final String $type;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Event.penalty(duration: $duration)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Event.penalty'))
      ..add(DiagnosticsProperty('duration', duration));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$Penalty &&
            const DeepCollectionEquality().equals(other.duration, duration));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(duration));

  @JsonKey(ignore: true)
  @override
  _$$PenaltyCopyWith<_$Penalty> get copyWith =>
      __$$PenaltyCopyWithImpl<_$Penalty>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String word) word,
    required TResult Function() enter,
    required TResult Function(Duration duration) penalty,
  }) {
    return penalty(duration);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(String word)? word,
    TResult Function()? enter,
    TResult Function(Duration duration)? penalty,
  }) {
    return penalty?.call(duration);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String word)? word,
    TResult Function()? enter,
    TResult Function(Duration duration)? penalty,
    required TResult orElse(),
  }) {
    if (penalty != null) {
      return penalty(duration);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Word value) word,
    required TResult Function(Enter value) enter,
    required TResult Function(Penalty value) penalty,
  }) {
    return penalty(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(Word value)? word,
    TResult Function(Enter value)? enter,
    TResult Function(Penalty value)? penalty,
  }) {
    return penalty?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Word value)? word,
    TResult Function(Enter value)? enter,
    TResult Function(Penalty value)? penalty,
    required TResult orElse(),
  }) {
    if (penalty != null) {
      return penalty(this);
    }
    return orElse();
  }

  @override
  Map<String, dynamic> toJson() {
    return _$$PenaltyToJson(this);
  }
}

abstract class Penalty implements Event {
  const factory Penalty(final Duration duration) = _$Penalty;

  factory Penalty.fromJson(Map<String, dynamic> json) = _$Penalty.fromJson;

  Duration get duration => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  _$$PenaltyCopyWith<_$Penalty> get copyWith =>
      throw _privateConstructorUsedError;
}

RecorderEvent _$RecorderEventFromJson(Map<String, dynamic> json) {
  return _RecorderEvent.fromJson(json);
}

/// @nodoc
mixin _$RecorderEvent {
  Duration get duration => throw _privateConstructorUsedError;
  Event get event => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RecorderEventCopyWith<RecorderEvent> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RecorderEventCopyWith<$Res> {
  factory $RecorderEventCopyWith(
          RecorderEvent value, $Res Function(RecorderEvent) then) =
      _$RecorderEventCopyWithImpl<$Res>;
  $Res call({Duration duration, Event event});

  $EventCopyWith<$Res> get event;
}

/// @nodoc
class _$RecorderEventCopyWithImpl<$Res>
    implements $RecorderEventCopyWith<$Res> {
  _$RecorderEventCopyWithImpl(this._value, this._then);

  final RecorderEvent _value;
  // ignore: unused_field
  final $Res Function(RecorderEvent) _then;

  @override
  $Res call({
    Object? duration = freezed,
    Object? event = freezed,
  }) {
    return _then(_value.copyWith(
      duration: duration == freezed
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as Duration,
      event: event == freezed
          ? _value.event
          : event // ignore: cast_nullable_to_non_nullable
              as Event,
    ));
  }

  @override
  $EventCopyWith<$Res> get event {
    return $EventCopyWith<$Res>(_value.event, (value) {
      return _then(_value.copyWith(event: value));
    });
  }
}

/// @nodoc
abstract class _$$_RecorderEventCopyWith<$Res>
    implements $RecorderEventCopyWith<$Res> {
  factory _$$_RecorderEventCopyWith(
          _$_RecorderEvent value, $Res Function(_$_RecorderEvent) then) =
      __$$_RecorderEventCopyWithImpl<$Res>;
  @override
  $Res call({Duration duration, Event event});

  @override
  $EventCopyWith<$Res> get event;
}

/// @nodoc
class __$$_RecorderEventCopyWithImpl<$Res>
    extends _$RecorderEventCopyWithImpl<$Res>
    implements _$$_RecorderEventCopyWith<$Res> {
  __$$_RecorderEventCopyWithImpl(
      _$_RecorderEvent _value, $Res Function(_$_RecorderEvent) _then)
      : super(_value, (v) => _then(v as _$_RecorderEvent));

  @override
  _$_RecorderEvent get _value => super._value as _$_RecorderEvent;

  @override
  $Res call({
    Object? duration = freezed,
    Object? event = freezed,
  }) {
    return _then(_$_RecorderEvent(
      duration: duration == freezed
          ? _value.duration
          : duration // ignore: cast_nullable_to_non_nullable
              as Duration,
      event: event == freezed
          ? _value.event
          : event // ignore: cast_nullable_to_non_nullable
              as Event,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$_RecorderEvent with DiagnosticableTreeMixin implements _RecorderEvent {
  const _$_RecorderEvent({required this.duration, required this.event});

  factory _$_RecorderEvent.fromJson(Map<String, dynamic> json) =>
      _$$_RecorderEventFromJson(json);

  @override
  final Duration duration;
  @override
  final Event event;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'RecorderEvent(duration: $duration, event: $event)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'RecorderEvent'))
      ..add(DiagnosticsProperty('duration', duration))
      ..add(DiagnosticsProperty('event', event));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_RecorderEvent &&
            const DeepCollectionEquality().equals(other.duration, duration) &&
            const DeepCollectionEquality().equals(other.event, event));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(duration),
      const DeepCollectionEquality().hash(event));

  @JsonKey(ignore: true)
  @override
  _$$_RecorderEventCopyWith<_$_RecorderEvent> get copyWith =>
      __$$_RecorderEventCopyWithImpl<_$_RecorderEvent>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_RecorderEventToJson(this);
  }
}

abstract class _RecorderEvent implements RecorderEvent {
  const factory _RecorderEvent(
      {required final Duration duration,
      required final Event event}) = _$_RecorderEvent;

  factory _RecorderEvent.fromJson(Map<String, dynamic> json) =
      _$_RecorderEvent.fromJson;

  @override
  Duration get duration => throw _privateConstructorUsedError;
  @override
  Event get event => throw _privateConstructorUsedError;
  @override
  @JsonKey(ignore: true)
  _$$_RecorderEventCopyWith<_$_RecorderEvent> get copyWith =>
      throw _privateConstructorUsedError;
}
