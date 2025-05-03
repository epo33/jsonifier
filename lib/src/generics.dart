import 'package:jsonifier/jsonifier.dart';

abstract interface class GenericTypeJsonifier {}

mixin OneGenericTypeJsonifierMixin<T> on TypeReifier<T>
    implements GenericTypeJsonifier, GenericTypeReifier {
  TypeReifier? get genericReifier;

  @override
  String get identifier =>
      buildIdentifier(baseIdentifier, genericReifier?.identifier);

  TypeJsonifier buildJsonifier<V>({
    required bool nullable,
    TypeReifier<V>? reifier,
  });

  ObjectIsA buildObjectIsA<V>(TypeScanner scanner, {required bool nullable});

  @override
  TypeJsonifier get nullReifier => nullable
      ? this as TypeJsonifier
      : buildJsonifier(nullable: true, reifier: genericReifier);

  @override
  TypeReifier getReifierFor(String identifier, Jsonifier jsonifier) {
    final reifier = jsonifier.getReifierFor<TypeReifier>(identifier);
    return reifier.callWithOneType(
      <V>() => buildJsonifier<V>(
        nullable: nullable,
        reifier: reifier as TypeReifier<V>,
      ),
    );
  }

  @override
  TypeReifier scanGenerics(TypeScanner scanner) {
    final generic = scanner
            .withObjectIsA(
              callWithOneType<ObjectIsA>(
                <V>() => buildObjectIsA<V>(scanner, nullable: false),
              ),
            )
            .scanObject() ??
        scanner
            .withObjectIsA(
              callWithOneType<ObjectIsA>(
                <V>() => buildObjectIsA<V>(
                  scanner,
                  nullable: true,
                ),
              ),
            )
            .scanObject();
    return generic == null
        ? buildJsonifier(nullable: nullable)
        : generic.callWithOneType(
            <V>() => buildJsonifier<V>(
              nullable: nullable,
              reifier: generic as TypeReifier<V>,
            ),
          );
  }
}
