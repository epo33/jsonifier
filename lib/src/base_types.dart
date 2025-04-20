import 'package:jsonifier/jsonifier.dart';

final class BaseTypeJsonifier<T> extends TypeJsonifier<T> {
  static const stringJsonfier = BaseTypeJsonifier<String>._('string');
  static const intJsonfier = BaseTypeJsonifier<int>._('int');
  static const doubleJsonfier = BaseTypeJsonifier<double>._('double');
  static const boolJsonfier = BaseTypeJsonifier<bool>._('bool');
  static const nullJsonfier = BaseTypeJsonifier<Null>._('null');

  const BaseTypeJsonifier._(this.identifier, {super.nullable});

  @override
  TypeJsonifier get nullJsonifier =>
      nullable ? this : BaseTypeJsonifier<T?>._(identifier, nullable: true);

  @override
  T fromJson(covariant json, Jsonifier jsonifier) => json as T;

  @override
  toJson(T object, Jsonifier jsonifier) => object;

  @override
  final String identifier;
}

final class DateTimeJsonifier extends StringEncodeJsonifier<DateTime> {
  const DateTimeJsonifier({super.nullable});

  @override
  String get identifier => "DateTime${nullable ? "?" : ""}";

  @override
  TypeJsonifier get nullJsonifier =>
      nullable ? this : DateTimeJsonifier(nullable: true);

  @override
  DateTime decodeValue(String value, Jsonifier jsonifier) =>
      DateTime.parse(value);

  @override
  String encodeValue(DateTime value, Jsonifier jsonifier) =>
      value.toIso8601String();
}

final class DurationJsonifier extends StringEncodeJsonifier<Duration> {
  const DurationJsonifier({super.nullable});

  @override
  String get identifier => "Duration${nullable ? "?" : ""}";

  @override
  TypeJsonifier get nullJsonifier =>
      nullable ? this : DurationJsonifier(nullable: true);

  @override
  Duration decodeValue(String value, Jsonifier jsonifier) =>
      Duration(microseconds: int.parse(value));

  @override
  String encodeValue(Duration value, Jsonifier jsonifier) =>
      value.inMicroseconds.toString();
}
