// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: non_constant_identifier_names

part of 'recorder.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$Word _$$WordFromJson(Map<String, dynamic> json) => _$Word(
      json['word'] as String,
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$WordToJson(_$Word instance) => <String, dynamic>{
      'word': instance.word,
      'runtimeType': instance.$type,
    };

_$Enter _$$EnterFromJson(Map<String, dynamic> json) => _$Enter(
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$EnterToJson(_$Enter instance) => <String, dynamic>{
      'runtimeType': instance.$type,
    };

_$Penalty _$$PenaltyFromJson(Map<String, dynamic> json) => _$Penalty(
      Duration(microseconds: json['duration'] as int),
      $type: json['runtimeType'] as String?,
    );

Map<String, dynamic> _$$PenaltyToJson(_$Penalty instance) => <String, dynamic>{
      'duration': instance.duration.inMicroseconds,
      'runtimeType': instance.$type,
    };

_$_RecorderEvent _$$_RecorderEventFromJson(Map<String, dynamic> json) =>
    _$_RecorderEvent(
      duration: Duration(microseconds: json['duration'] as int),
      event: Event.fromJson(json['event'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$_RecorderEventToJson(_$_RecorderEvent instance) =>
    <String, dynamic>{
      'duration': instance.duration.inMicroseconds,
      'event': instance.event,
    };
