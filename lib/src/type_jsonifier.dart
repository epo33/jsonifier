import 'package:jsonifier/jsonifier.dart';
import 'package:jsonifier/src/base_types.dart';

typedef FromString<T> = T? Function(String s);

abstract class TypeJsonifier<T> extends TypeReifier<T> {
  static const baseJsonifiers = <TypeJsonifier>[
    BaseTypeJsonifier.stringJsonfier,
    BaseTypeJsonifier.intJsonfier,
    BaseTypeJsonifier.doubleJsonfier,
    BaseTypeJsonifier.boolJsonfier,
    DateTimeJsonifier(),
    DurationJsonifier(),
    Uint8ListJsonifier(),
    UriJsonifier(),
    IterableJsonifier.listJsonifier,
    IterableJsonifier.setJsonifier,
    MapJsonifier.jsonMapJsonifier,
  ];

  const TypeJsonifier(
    super.baseIdentifier, {
    super.nullable,
    super.priority,
  });

  @override
  TypeJsonifier get nullReifier;

  FromString<T>? get decodeString => null;

  dynamic fromJson(covariant dynamic json);

  dynamic toJson(covariant dynamic object);

  bool canJsonify(object, Jsonifier jsonifier) => object is T;

  dynamic encode(
    covariant dynamic object,
    Jsonifier jsonifier,
  ) =>
      object;

  TypeJsonifier typeJsonifierFor(
    covariant dynamic object,
    Jsonifier jsonifier,
  ) =>
      this;

  dynamic decode(covariant dynamic object, Jsonifier jsonifier) => object;
}
