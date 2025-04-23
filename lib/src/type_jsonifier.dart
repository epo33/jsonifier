import 'package:jsonifier/jsonifier.dart';
import 'package:jsonifier/src/base_types.dart';
import 'package:jsonifier/src/iterable_jsonifier.dart';

abstract class TypeJsonifier<T> {
  static const baseJsonifiers = <TypeJsonifier>[
    BaseTypeJsonifier.stringJsonfier,
    BaseTypeJsonifier.intJsonfier,
    BaseTypeJsonifier.doubleJsonfier,
    BaseTypeJsonifier.boolJsonfier,
    DateTimeJsonifier(),
    DurationJsonifier(),
  ];

  const TypeJsonifier({this.nullable = false});

  Type get jsonifiedType => T;

  TypeJsonifier get nullJsonifier;

  String get identifier;

  final bool nullable;

  dynamic fromJson(covariant dynamic json);

  dynamic toJson(covariant dynamic object);

  bool canJsonify(object, covariant Jsonifier jsonifier) => object is T;

  TypeJsonifier get jsonifierIterable => IterableJsonifier.iterableOf<T>(this);

  TypeJsonifier get jsonifierList => IterableJsonifier.listOf<T>(this);

  TypeJsonifier get jsonifierSet => IterableJsonifier.setOf<T>(this);

  MapJsonifier get mapJsonifiers => MapJsonifier<T>(valueJsonifier: this);

  bool objectIsA(object, bool Function<V>(dynamic) isA) => isA<T>(object);

  dynamic encode(covariant dynamic object, Jsonifier jsonifier) => object;

  dynamic decode(covariant dynamic object, Jsonifier jsonifier) => object;

  @override
  String toString() => identifier;

  @override
  bool operator ==(other) =>
      other is TypeJsonifier &&
      other.identifier == identifier &&
      other.jsonifiedType == jsonifiedType;

  @override
  int get hashCode => jsonifiedType.hashCode;
}
