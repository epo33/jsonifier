import 'package:collection/collection.dart';
import 'package:jsonifier/jsonifier.dart';

abstract class GenericClass<C extends Object, Bounds1, Bounds2, Bounds3> {
  const GenericClass();

  GenericClassJsonifier<C> typeJsonifier(String baseIdentifier) =>
      GenericClassJsonifier<C>(baseIdentifier: baseIdentifier, generic: this);

  JsonMap toJson(C object);

  /// If overrided, must return an iterable containing [nGenericType] entries witch can be :
  /// - a value typed as Bounds(N+1) where N is the index in the iterable
  /// - the Nth generic type expected.
  Iterable typesSignatureOf(C object) => [Bounds1, Bounds2, Bounds3];

  int get nGenericTypes;

  C _fromJson<T1 extends Bounds1, T2 extends Bounds2, T3 extends Bounds3>(
    JsonMap json,
  );
}

abstract class GenericClass1<C extends Object, Bounds>
    extends GenericClass<C, Bounds, Object, Object> {
  const GenericClass1();

  C fromJson<T extends Bounds>(JsonMap jsonMap);

  @override
  int get nGenericTypes => 1;

  @override
  C _fromJson<T1 extends Bounds, T2 extends Object, T3 extends Object>(
          JsonMap json) =>
      fromJson<T1>(json);
}

abstract class GenericClass2<C extends Object, Bounds1, Bounds2>
    extends GenericClass<C, Bounds1, Bounds2, Object> {
  const GenericClass2();

  C fromJson<T1 extends Bounds1, T2 extends Bounds2>(JsonMap json);

  @override
  int get nGenericTypes => 2;

  @override
  C _fromJson<T1 extends Bounds1, T2 extends Bounds2, T3 extends Object>(
          JsonMap json) =>
      fromJson<T1, T2>(json);
}

abstract class GenericClass3<C extends Object, Bounds1, Bounds2, Bounds3>
    extends GenericClass<C, Bounds1, Bounds2, Bounds3> {
  const GenericClass3();

  C fromJson<T1 extends Bounds1, T2 extends Bounds2, T3 extends Bounds3>(
      JsonMap json);

  @override
  JsonMap toJson(C object);

  @override
  int get nGenericTypes => 3;

  @override
  C _fromJson<T1 extends Bounds1, T2 extends Bounds2, T3 extends Bounds3>(
          JsonMap json) =>
      fromJson<T1, T2, T3>(json);
}

final class GenericClassJsonifier<C extends Object> extends ClassJsonifier<C> {
  const GenericClassJsonifier({
    required this.baseIdentifier,
    required this.generic,
    this.subJsonifiers = const [],
    super.nullable,
  });

  final String baseIdentifier;

  final GenericClass<C, dynamic, dynamic, dynamic> generic;

  final Iterable<TypeJsonifier> subJsonifiers;

  @override
  String get identifier => buildIdentifier(
        subJsonifiers.isEmpty
            ? baseIdentifier
            : [
                baseIdentifier,
                ...subJsonifiers.map((jsonifier) => jsonifier.identifier),
              ].join("_"),
      );

  @override
  bool canJsonify(object, Jsonifier jsonifier) => object is C;

  @override
  C fromJson(JsonMap json) {
    assert(subJsonifiers.length == 3);
    return subJsonifiers //
        .elementAt(0)
        .callWithType(
          <T1>() => subJsonifiers //
              .elementAt(1)
              .callWithType(
                <T2>() => subJsonifiers.elementAt(2).callWithType(
                    <T3>() => generic._fromJson<T1, T2, T3>(json)),
              ),
        );
  }

  @override
  TypeJsonifier get nullJsonifier => nullable
      ? this
      : GenericClassJsonifier<C>(
          baseIdentifier: baseIdentifier,
          generic: generic,
          subJsonifiers: subJsonifiers,
          nullable: true,
        );

  @override
  JsonMap toJson(C object) => generic.toJson(object);

  @override
  TypeJsonifier typeJsonifierFor(JsonMap object, Jsonifier jsonifier) {
    final subJsonifiers = <TypeJsonifier>[];
    var index = 0;
    while (true) {
      final type = object[_typeKey(jsonifier, index++)];
      if (type is! String) break;
      final subJsonifier = jsonifier.typeJsonifiers.identifiedBy(type);
      if (subJsonifier == null) {
        throw "No jsonifier found for type $type";
      }
      subJsonifiers.add(subJsonifier);
    }
    while (subJsonifiers.length < 3) {
      subJsonifiers.add(_ObjectJsonifier());
    }
    return GenericClassJsonifier<C>(
      baseIdentifier: baseIdentifier,
      generic: generic,
      subJsonifiers: subJsonifiers,
      nullable: nullable,
    );
  }

  @override
  JsonMap encode(JsonMap object, Jsonifier jsonifier, C source) {
    final signatures = generic.typesSignatureOf(source);
    assert(signatures.length >= generic.nGenericTypes);
    final subJsonifiers = signatures.map(
      (value) => value is Type
          ? jsonifier //
              .typeJsonifiers
              .firstWhereOrNull(
              (jsonifier) => jsonifier.jsonifiedType == value,
            )
          : jsonifier //
              .typeJsonifiers
              .jsonifierFor(value, jsonifier),
    );
    for (var i = 0; i < subJsonifiers.length; i++) {
      final typeJsonifier = subJsonifiers.elementAt(i);
      if (typeJsonifier == null) {
        final signature = signatures.elementAt(i);
        throw "No jsonifier found for type ${signature is Type ? signature : signature.runtimeType}";
      } else {
        object[_typeKey(jsonifier, i)] = typeJsonifier.identifier;
      }
    }
    return super.encode(object, jsonifier, source);
  }

  String _typeKey(Jsonifier jsonifier, int index) =>
      "${jsonifier.reservedStringPrefix}type_$index";
}

class _ObjectJsonifier extends TypeJsonifier<Object> {
  @override
  fromJson(covariant json) => throw UnimplementedError();

  @override
  String get identifier => "Object";

  @override
  TypeJsonifier get nullJsonifier => throw UnimplementedError();

  @override
  toJson(covariant object) => throw UnimplementedError();
}
