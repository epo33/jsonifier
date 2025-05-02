import 'package:collection/collection.dart';
import 'package:jsonifier/jsonifier.dart';

final class EnumJsonifier<E extends Enum> extends TypeJsonifier<E>
    with StringEncodeJsonifier<E> {
  const EnumJsonifier(
    super.baseIdentifier, {
    required this.values,
    super.nullable,
  }) : assert(
          E != Enum,
          "EnumJsonifier<E> must be used with a specific enum type E.",
        );

  final Iterable<E> values;

  @override
  TypeJsonifier get nullReifier => nullable
      ? this
      : EnumJsonifier<E>(
          baseIdentifier,
          values: values,
          nullable: true,
        );

  @override
  E fromJson(String json) =>
      values.firstWhereOrNull((e) => e.name == json) ??
      (throw "Invalid enum value: $json for $identifier.");

  @override
  String toJson(E object) => object.name;

  dynamic callWithEnumType(dynamic Function<T extends Enum>() called) =>
      called<E>();
}
