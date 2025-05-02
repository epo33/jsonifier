import 'package:collection/collection.dart';
import 'package:jsonifier/jsonifier.dart';

part 'generic_wrappers.dart';

final class GenericClassJsonifier<C extends Object> extends ClassJsonifier<C>
    implements GenericTypeReifier {
  const GenericClassJsonifier(
    super.baseIdentifier, {
    required this.generic,
    this.reifiers = const [],
    super.nullable,
    super.priority,
  });

  final GenericClass<C, dynamic, dynamic, dynamic> generic;

  final Iterable<TypeReifier> reifiers;

  @override
  String get identifier => buildIdentifier(
        reifiers.isEmpty
            ? baseIdentifier
            : [
                baseIdentifier,
                ...reifiers.map((reifier) => reifier.baseIdentifier),
              ].join("_"),
      );

  @override
  C fromJson(JsonMap json) {
    final reifiers = this.reifiers.toList();
    assert(reifiers.length == 3);
    return reifiers[0] //
        .callWithThreeTypes(
      <T1, T2, T3>() => generic._fromJson<T1, T2, T3>(json),
      reifiers[1],
      reifiers[2],
    );
  }

  @override
  TypeJsonifier get nullReifier => nullable
      ? this
      : GenericClassJsonifier<C>(
          baseIdentifier,
          generic: generic,
          reifiers: reifiers,
          nullable: true,
          priority: priority,
        );

  @override
  JsonMap toJson(C object) => generic.toJson(object);

  @override
  TypeJsonifier scanGenerics(TypeScanner scanner) {
    final boundedGeneric = generic._getBoundedGeneric(scanner);
    return GenericClassJsonifier<C>(
      baseIdentifier,
      generic: boundedGeneric,
      reifiers: reifiers,
      nullable: nullable,
    );
  }

  @override
  TypeJsonifier typeJsonifierFor(JsonMap object, Jsonifier jsonifier) {
    final key = _typeKey(jsonifier);
    final reifiers = object
        .asString(key)!
        .split(".")
        .map(jsonifier.typeReifierForIdentifier)
        .toList();
    while (reifiers.length < 3) {
      reifiers.add(const TypeReifier<Object>(""));
    }
    object.remove(key);
    return GenericClassJsonifier<C>(
      baseIdentifier,
      generic: generic,
      reifiers: reifiers,
      nullable: nullable,
    );
  }

  @override
  JsonMap encode(JsonMap object, Jsonifier jsonifier) {
    object = super.encode(object, jsonifier);
    final signature = reifiers //
        .map((reifier) => reifier.baseIdentifier)
        .join(".");
    object[_typeKey(jsonifier)] = signature;
    return object;
  }

  String _typeKey(Jsonifier jsonifier) =>
      "${jsonifier.reservedStringPrefix}type";
}
