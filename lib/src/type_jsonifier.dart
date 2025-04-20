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
    MapJsonifier(),
  ];

  const TypeJsonifier({this.nullable = false});

  TypeJsonifier get nullJsonifier;

  String get identifier;

  final bool nullable;

  dynamic fromJson(json, Jsonifier jsonifier);

  dynamic toJson(covariant dynamic object, Jsonifier jsonifier);

  bool canJsonify(object, covariant Jsonifier jsonifier) => object is T;

  Iterable<IterableJsonifier> iterableJsonifiers(
    covariant Jsonifier jsonifier,
  ) =>
      [
        listJsonifiers(jsonifier),
        setJsonifiers(jsonifier),
      ];

  ListJsonifier<T> listJsonifiers(covariant Jsonifier jsonifier) =>
      ListJsonifier<T>(this);

  SetJsonifier<T> setJsonifiers(covariant Jsonifier jsonifier) =>
      SetJsonifier<T>(this);

  Iterable<IterableJsonifier> mapJsonifiers(covariant Jsonifier jsonifier) =>
      [];

  Iterable<IterableJsonifier> associatedJsonifiers(
          covariant Jsonifier jsonifier) =>
      [];
}
