import 'dart:convert';
import 'dart:typed_data';

import 'package:jsonifier/jsonifier.dart';

final class BaseTypeJsonifier<T> extends TypeJsonifier<T> {
  static const stringJsonfier = BaseTypeJsonifier<String>._('string');
  static const intJsonfier = BaseTypeJsonifier<int>._('int');
  static const doubleJsonfier = BaseTypeJsonifier<double>._('double');
  static const boolJsonfier = BaseTypeJsonifier<bool>._('bool');
  static const nullJsonfier = BaseTypeJsonifier<Null>._('null');

  const BaseTypeJsonifier._(super.baseIdentifier, {super.nullable});

  @override
  TypeJsonifier get nullReifier =>
      nullable ? this : BaseTypeJsonifier<T?>._(baseIdentifier, nullable: true);

  @override
  FromString<T>? get decodeString {
    switch (T) {
      // ignore: type_literal_in_constant_pattern
      case String:
        return (s) => s as T;
      // ignore: type_literal_in_constant_pattern
      case int:
        return (s) => s.isEmpty ? null as T? : int.parse(s) as T;
      // ignore: type_literal_in_constant_pattern
      case double:
        return (s) => s.isEmpty ? null as T? : double.parse(s) as T;
      // ignore: type_literal_in_constant_pattern
      case bool:
        return (s) => s.isEmpty ? null as T? : bool.parse(s) as T;
      default:
        return null;
    }
  }

  @override
  T fromJson(json) => json as T;

  @override
  toJson(T object) => object;
}

final class DateTimeJsonifier extends TypeJsonifier<DateTime>
    with StringEncodeJsonifier<DateTime> {
  static const dateTimeIdentifier = "DateTime";

  const DateTimeJsonifier({super.nullable}) : super(dateTimeIdentifier);

  @override
  TypeJsonifier get nullReifier =>
      nullable ? this : DateTimeJsonifier(nullable: true);

  @override
  DateTime fromJson(String json) => DateTime.parse(json);

  @override
  String toJson(DateTime object) => object.toIso8601String();
}

final class DurationJsonifier extends TypeJsonifier<Duration>
    with StringEncodeJsonifier<Duration> {
  static const durationIdentifier = "Duration";

  const DurationJsonifier({super.nullable}) : super(durationIdentifier);

  @override
  TypeJsonifier get nullReifier =>
      nullable ? this : DurationJsonifier(nullable: true);

  @override
  Duration fromJson(String json) => Duration(microseconds: int.parse(json));

  @override
  String toJson(Duration object) => object.inMicroseconds.toString();
}

final class Uint8ListJsonifier extends TypeJsonifier<Uint8List>
    with StringEncodeJsonifier<Uint8List> {
  static const uint8ListIdentifier = "Uint8List";

  const Uint8ListJsonifier({super.nullable}) : super(uint8ListIdentifier);

  @override
  TypeJsonifier get nullReifier =>
      nullable ? this : Uint8ListJsonifier(nullable: true);

  @override
  Uint8List fromJson(String json) =>
      json.isEmpty ? Uint8List(0) : Uint8List.fromList(base64Decode(json));

  @override
  String toJson(Uint8List object) => object.isEmpty ? "" : base64Encode(object);
}

final class UriJsonifier extends TypeJsonifier<Uri>
    with StringEncodeJsonifier<Uri> {
  static const uriIdentifier = "Uri";

  const UriJsonifier({super.nullable}) : super(uriIdentifier);

  @override
  TypeJsonifier get nullReifier =>
      nullable ? this : UriJsonifier(nullable: true);

  @override
  Uri fromJson(String json) => Uri.parse(json);

  @override
  String toJson(Uri object) => object.toString();
}
