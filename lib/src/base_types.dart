import 'dart:convert';
import 'dart:typed_data';

import 'package:jsonifier/jsonifier.dart';

final class BaseTypeJsonifier<T> extends TypeJsonifier<T> {
  static const stringJsonfier = BaseTypeJsonifier<String>._('string');
  static const intJsonfier = BaseTypeJsonifier<int>._('int');
  static const doubleJsonfier = BaseTypeJsonifier<double>._('double');
  static const boolJsonfier = BaseTypeJsonifier<bool>._('bool');
  static const nullJsonfier = BaseTypeJsonifier<Null>._('null');

  const BaseTypeJsonifier._(this._identifier, {super.nullable});

  @override
  String get identifier => "$_identifier${nullable ? "?" : ""}";

  @override
  TypeJsonifier get nullJsonifier =>
      nullable ? this : BaseTypeJsonifier<T?>._(identifier, nullable: true);

  @override
  T fromJson(json) => json as T;

  @override
  toJson(T object) => object;

  final String _identifier;
}

final class DateTimeJsonifier extends StringEncodeJsonifier<DateTime> {
  const DateTimeJsonifier({super.nullable}) : super(identifier: "DateTime");

  @override
  TypeJsonifier get nullJsonifier =>
      nullable ? this : DateTimeJsonifier(nullable: true);

  @override
  DateTime fromJson(String json) => DateTime.parse(json);

  @override
  String toJson(DateTime object) => object.toIso8601String();
}

final class DurationJsonifier extends StringEncodeJsonifier<Duration> {
  const DurationJsonifier({super.nullable}) : super(identifier: "Duration");

  @override
  TypeJsonifier get nullJsonifier =>
      nullable ? this : DurationJsonifier(nullable: true);

  @override
  Duration fromJson(String json) => Duration(microseconds: int.parse(json));

  @override
  String toJson(Duration object) => object.inMicroseconds.toString();
}

final class Uint8ListJsonifier extends StringEncodeJsonifier<Uint8List> {
  const Uint8ListJsonifier({super.nullable}) : super(identifier: "Uint8List");

  @override
  TypeJsonifier get nullJsonifier =>
      nullable ? this : Uint8ListJsonifier(nullable: true);

  @override
  Uint8List fromJson(String json) =>
      json.isEmpty ? Uint8List(0) : Uint8List.fromList(base64Decode(json));

  @override
  String toJson(Uint8List object) => object.isEmpty ? "" : base64Encode(object);
}
