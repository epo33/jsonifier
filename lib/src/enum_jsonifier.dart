import 'package:collection/collection.dart';
import 'package:jsonifier/jsonifier.dart';

final class EnumJsonifier<E extends Enum> extends TypeJsonifier<E>
    with StringEncodeJsonifier<E> {
  const EnumJsonifier({
    required String identifier,
    required this.values,
    super.nullable,
  })  : assert(
          E != Enum,
          "EnumJsonifier<E> must be used with a specific enum type E.",
        ),
        _identifier = identifier;

  final Iterable<E> values;

  @override
  String get identifier => buildIdentifier(_identifier);

  @override
  TypeJsonifier get nullJsonifier => nullable
      ? this
      : EnumJsonifier<E>(
          identifier: identifier,
          values: values,
          nullable: true,
        );

  @override
  E fromJson(String json) =>
      values.firstWhereOrNull((e) => e.name == json) ??
      (throw "Invalid enum value: $json for $identifier.");

  @override
  String toJson(E object) => object.name;

  final String _identifier;
}
