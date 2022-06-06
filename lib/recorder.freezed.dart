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

/// @nodoc
mixin _$Event {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String key) letter,
    required TResult Function() backspace,
    required TResult Function() enter,
    required TResult Function(Duration duration) penalty,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(String key)? letter,
    TResult Function()? backspace,
    TResult Function()? enter,
    TResult Function(Duration duration)? penalty,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String key)? letter,
    TResult Function()? backspace,
    TResult Function()? enter,
    TResult Function(Duration duration)? penalty,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Letter value) letter,
    required TResult Function(Backspace value) backspace,
    required TResult Function(Enter value) enter,
    required TResult Function(Penalty value) penalty,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(Letter value)? letter,
    TResult Function(Backspace value)? backspace,
    TResult Function(Enter value)? enter,
    TResult Function(Penalty value)? penalty,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Letter value)? letter,
    TResult Function(Backspace value)? backspace,
    TResult Function(Enter value)? enter,
    TResult Function(Penalty value)? penalty,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
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
abstract class _$$LetterCopyWith<$Res> {
  factory _$$LetterCopyWith(_$Letter value, $Res Function(_$Letter) then) =
      __$$LetterCopyWithImpl<$Res>;
  $Res call({String key});
}

/// @nodoc
class __$$LetterCopyWithImpl<$Res> extends _$EventCopyWithImpl<$Res>
    implements _$$LetterCopyWith<$Res> {
  __$$LetterCopyWithImpl(_$Letter _value, $Res Function(_$Letter) _then)
      : super(_value, (v) => _then(v as _$Letter));

  @override
  _$Letter get _value => super._value as _$Letter;

  @override
  $Res call({
    Object? key = freezed,
  }) {
    return _then(_$Letter(
      key == freezed
          ? _value.key
          : key // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$Letter with DiagnosticableTreeMixin implements Letter {
  const _$Letter(this.key);

  @override
  final String key;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Event.letter(key: $key)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'Event.letter'))
      ..add(DiagnosticsProperty('key', key));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$Letter &&
            const DeepCollectionEquality().equals(other.key, key));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(key));

  @JsonKey(ignore: true)
  @override
  _$$LetterCopyWith<_$Letter> get copyWith =>
      __$$LetterCopyWithImpl<_$Letter>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String key) letter,
    required TResult Function() backspace,
    required TResult Function() enter,
    required TResult Function(Duration duration) penalty,
  }) {
    return letter(key);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(String key)? letter,
    TResult Function()? backspace,
    TResult Function()? enter,
    TResult Function(Duration duration)? penalty,
  }) {
    return letter?.call(key);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String key)? letter,
    TResult Function()? backspace,
    TResult Function()? enter,
    TResult Function(Duration duration)? penalty,
    required TResult orElse(),
  }) {
    if (letter != null) {
      return letter(key);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Letter value) letter,
    required TResult Function(Backspace value) backspace,
    required TResult Function(Enter value) enter,
    required TResult Function(Penalty value) penalty,
  }) {
    return letter(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(Letter value)? letter,
    TResult Function(Backspace value)? backspace,
    TResult Function(Enter value)? enter,
    TResult Function(Penalty value)? penalty,
  }) {
    return letter?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Letter value)? letter,
    TResult Function(Backspace value)? backspace,
    TResult Function(Enter value)? enter,
    TResult Function(Penalty value)? penalty,
    required TResult orElse(),
  }) {
    if (letter != null) {
      return letter(this);
    }
    return orElse();
  }
}

abstract class Letter implements Event {
  const factory Letter(final String key) = _$Letter;

  String get key => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  _$$LetterCopyWith<_$Letter> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$BackspaceCopyWith<$Res> {
  factory _$$BackspaceCopyWith(
          _$Backspace value, $Res Function(_$Backspace) then) =
      __$$BackspaceCopyWithImpl<$Res>;
}

/// @nodoc
class __$$BackspaceCopyWithImpl<$Res> extends _$EventCopyWithImpl<$Res>
    implements _$$BackspaceCopyWith<$Res> {
  __$$BackspaceCopyWithImpl(
      _$Backspace _value, $Res Function(_$Backspace) _then)
      : super(_value, (v) => _then(v as _$Backspace));

  @override
  _$Backspace get _value => super._value as _$Backspace;
}

/// @nodoc

class _$Backspace with DiagnosticableTreeMixin implements Backspace {
  const _$Backspace();

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'Event.backspace()';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('type', 'Event.backspace'));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$Backspace);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String key) letter,
    required TResult Function() backspace,
    required TResult Function() enter,
    required TResult Function(Duration duration) penalty,
  }) {
    return backspace();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(String key)? letter,
    TResult Function()? backspace,
    TResult Function()? enter,
    TResult Function(Duration duration)? penalty,
  }) {
    return backspace?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String key)? letter,
    TResult Function()? backspace,
    TResult Function()? enter,
    TResult Function(Duration duration)? penalty,
    required TResult orElse(),
  }) {
    if (backspace != null) {
      return backspace();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Letter value) letter,
    required TResult Function(Backspace value) backspace,
    required TResult Function(Enter value) enter,
    required TResult Function(Penalty value) penalty,
  }) {
    return backspace(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(Letter value)? letter,
    TResult Function(Backspace value)? backspace,
    TResult Function(Enter value)? enter,
    TResult Function(Penalty value)? penalty,
  }) {
    return backspace?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Letter value)? letter,
    TResult Function(Backspace value)? backspace,
    TResult Function(Enter value)? enter,
    TResult Function(Penalty value)? penalty,
    required TResult orElse(),
  }) {
    if (backspace != null) {
      return backspace(this);
    }
    return orElse();
  }
}

abstract class Backspace implements Event {
  const factory Backspace() = _$Backspace;
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

class _$Enter with DiagnosticableTreeMixin implements Enter {
  const _$Enter();

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

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(String key) letter,
    required TResult Function() backspace,
    required TResult Function() enter,
    required TResult Function(Duration duration) penalty,
  }) {
    return enter();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(String key)? letter,
    TResult Function()? backspace,
    TResult Function()? enter,
    TResult Function(Duration duration)? penalty,
  }) {
    return enter?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String key)? letter,
    TResult Function()? backspace,
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
    required TResult Function(Letter value) letter,
    required TResult Function(Backspace value) backspace,
    required TResult Function(Enter value) enter,
    required TResult Function(Penalty value) penalty,
  }) {
    return enter(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(Letter value)? letter,
    TResult Function(Backspace value)? backspace,
    TResult Function(Enter value)? enter,
    TResult Function(Penalty value)? penalty,
  }) {
    return enter?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Letter value)? letter,
    TResult Function(Backspace value)? backspace,
    TResult Function(Enter value)? enter,
    TResult Function(Penalty value)? penalty,
    required TResult orElse(),
  }) {
    if (enter != null) {
      return enter(this);
    }
    return orElse();
  }
}

abstract class Enter implements Event {
  const factory Enter() = _$Enter;
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

class _$Penalty with DiagnosticableTreeMixin implements Penalty {
  const _$Penalty(this.duration);

  @override
  final Duration duration;

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
    required TResult Function(String key) letter,
    required TResult Function() backspace,
    required TResult Function() enter,
    required TResult Function(Duration duration) penalty,
  }) {
    return penalty(duration);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(String key)? letter,
    TResult Function()? backspace,
    TResult Function()? enter,
    TResult Function(Duration duration)? penalty,
  }) {
    return penalty?.call(duration);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(String key)? letter,
    TResult Function()? backspace,
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
    required TResult Function(Letter value) letter,
    required TResult Function(Backspace value) backspace,
    required TResult Function(Enter value) enter,
    required TResult Function(Penalty value) penalty,
  }) {
    return penalty(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(Letter value)? letter,
    TResult Function(Backspace value)? backspace,
    TResult Function(Enter value)? enter,
    TResult Function(Penalty value)? penalty,
  }) {
    return penalty?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Letter value)? letter,
    TResult Function(Backspace value)? backspace,
    TResult Function(Enter value)? enter,
    TResult Function(Penalty value)? penalty,
    required TResult orElse(),
  }) {
    if (penalty != null) {
      return penalty(this);
    }
    return orElse();
  }
}

abstract class Penalty implements Event {
  const factory Penalty(final Duration duration) = _$Penalty;

  Duration get duration => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  _$$PenaltyCopyWith<_$Penalty> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$RecorderEvent {
  Duration get duration => throw _privateConstructorUsedError;
  Event get event => throw _privateConstructorUsedError;

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

class _$_RecorderEvent with DiagnosticableTreeMixin implements _RecorderEvent {
  const _$_RecorderEvent({required this.duration, required this.event});

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

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(duration),
      const DeepCollectionEquality().hash(event));

  @JsonKey(ignore: true)
  @override
  _$$_RecorderEventCopyWith<_$_RecorderEvent> get copyWith =>
      __$$_RecorderEventCopyWithImpl<_$_RecorderEvent>(this, _$identity);
}

abstract class _RecorderEvent implements RecorderEvent {
  const factory _RecorderEvent(
      {required final Duration duration,
      required final Event event}) = _$_RecorderEvent;

  @override
  Duration get duration => throw _privateConstructorUsedError;
  @override
  Event get event => throw _privateConstructorUsedError;
  @override
  @JsonKey(ignore: true)
  _$$_RecorderEventCopyWith<_$_RecorderEvent> get copyWith =>
      throw _privateConstructorUsedError;
}
