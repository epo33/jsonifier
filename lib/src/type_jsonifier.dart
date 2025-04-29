import 'package:jsonifier/jsonifier.dart';
import 'package:jsonifier/src/base_types.dart';

typedef FromString<T> = T? Function(String s);

abstract class TypeJsonifier<T> {
  static const baseJsonifiers = <TypeJsonifier>[
    BaseTypeJsonifier.stringJsonfier,
    BaseTypeJsonifier.intJsonfier,
    BaseTypeJsonifier.doubleJsonfier,
    BaseTypeJsonifier.boolJsonfier,
    DateTimeJsonifier(),
    DurationJsonifier(),
    Uint8ListJsonifier(),
    UriJsonifier(),
  ];

  const TypeJsonifier({this.nullable = false});

  Type get jsonifiedType => T;

  TypeJsonifier get nullJsonifier;

  String get identifier;

  final bool nullable;

  FromString<T>? get decodeString => null;

  dynamic fromJson(covariant dynamic json);

  dynamic toJson(covariant dynamic object);

  bool canJsonify(object, Jsonifier jsonifier) => object is T;

  TypeJsonifier get jsonifierIterable => IterableJsonifier.iterableOf<T>(this);

  TypeJsonifier get jsonifierList => IterableJsonifier.listOf<T>(this);

  TypeJsonifier get jsonifierSet => IterableJsonifier.setOf<T>(this);

  MapJsonifier get mapJsonifiers => MapJsonifier<T>(valueJsonifier: this);

  bool objectIsA(object, bool Function<V>(dynamic) isA) => isA<T>(object);

  dynamic callWithType(dynamic Function<C>() called) => called<T>();

  int get priority => 0;

  dynamic encode(
    covariant dynamic object,
    Jsonifier jsonifier,
    covariant source,
  ) =>
      object;

  TypeJsonifier typeJsonifierFor(
    covariant dynamic object,
    Jsonifier jsonifier,
  ) =>
      this;

  dynamic decode(covariant dynamic object, Jsonifier jsonifier) => object;

  @override
  String toString() => identifier;

  String buildIdentifier(String baseIdentifier, [String? subType]) =>
      subType == null
          ? nullable
              ? "$baseIdentifier?"
              : baseIdentifier
          : nullable
              ? "$baseIdentifier?.$subType"
              : "$baseIdentifier.$subType";

  @override
  bool operator ==(other) =>
      other is TypeJsonifier &&
      other.identifier == identifier &&
      other.jsonifiedType == jsonifiedType;

  @override
  int get hashCode => jsonifiedType.hashCode;
}
