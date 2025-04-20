import 'package:collection/collection.dart';
import 'package:jsonifier/jsonifier.dart';

final class EnumJsonifier<E extends Enum> extends StringEncodeJsonifier<E> {
  const EnumJsonifier({
    required this.identifier,
    required this.values,
    super.nullable,
  });

  @override
  final String identifier;

  final Iterable<E> values;

  @override
  TypeJsonifier get nullJsonifier => nullable
      ? this
      : EnumJsonifier<E>(
          identifier: identifier,
          values: values,
          nullable: true,
        );

  @override
  E decodeValue(String value, Jsonifier jsonifier) =>
      values.firstWhereOrNull((e) => e.name == value) ??
      (throw "Invalid enum value: $value for $identifier.");

  @override
  String encodeValue(E value, Jsonifier jsonifier) => value.name;
}
