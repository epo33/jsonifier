import 'package:jsonifier/jsonifier.dart';

sealed class IterableJsonifier<T, L> extends TypeJsonifier<L> {
  static const iterableIdentifier = "Iterable";
  static const listIdentifier = "List";
  static const setIdentifier = "Set";

  static TypeJsonifier iterableOf<T>(TypeJsonifier<T> typeJsonifier) =>
      _IterableJsonifier<T, Iterable<T>>(typeJsonifier);

  static TypeJsonifier listOf<T>(TypeJsonifier<T> typeJsonifier) =>
      _ListJsonifier<T, List<T>>(typeJsonifier);

  static TypeJsonifier setOf<T>(TypeJsonifier<T> typeJsonifier) =>
      _SetJsonifier<T, Set<T>>(typeJsonifier);

  static TypeJsonifier? identifyJsonifier(
    Iterable iterable,
    Jsonifier jsonifier,
  ) {
    if (iterable.isEmpty) return null;
    final type = iterable.last;
    if (type is! String) return null;
    return jsonifier.typeJsonifiers.identifiedBy(type);
  }

  const IterableJsonifier({super.nullable});
}

final class _IterableJsonifier<T, L> extends IterableJsonifier<T, L> {
  const _IterableJsonifier(this.itemJsonifier, {super.nullable});

  final TypeJsonifier itemJsonifier;

  @override
  String get identifier =>
      "${IterableJsonifier.iterableIdentifier}${nullable ? "?" : ""}.${itemJsonifier.identifier}";

  @override
  TypeJsonifier get nullJsonifier => nullable
      ? this
      : _IterableJsonifier<T, Iterable<T>?>(
          itemJsonifier,
          nullable: nullable,
        );

  @override
  Iterable<T> fromJson(json) {
    if (json is! Iterable || json.isEmpty) {
      throw "Invalid json for $identifier.";
    }
    return json.cast<T>().toList();
  }

  @override
  dynamic toJson(Iterable object) => object //
      .cast<dynamic>()
      .toList();

  @override
  encode(Iterable object, Jsonifier jsonifier) {
    final list = object //
        .map((item) => jsonifier.toJson(item))
        .toList()
      ..add(identifier);
    return list;
  }

  @override
  decode(Iterable object, Jsonifier jsonifier) {
    final list = object.toList();
    list.removeLast();
    return list //
        .map((item) => jsonifier.fromJson(item))
        .toList()
      ..cast<T>();
  }
}

final class _ListJsonifier<T, L> extends _IterableJsonifier<T, L> {
  const _ListJsonifier(super.itemJsonifier, {super.nullable});

  @override
  String get identifier =>
      "${IterableJsonifier.listIdentifier}${nullable ? "?" : ""}.${itemJsonifier.identifier}";

  @override
  bool canJsonify(object, Jsonifier jsonifier) =>
      object is Iterable<T> && object is! Set;

  @override
  TypeJsonifier get nullJsonifier => nullable
      ? this
      : _ListJsonifier<T, List<T>?>(itemJsonifier, nullable: true);

  @override
  List<T> fromJson(covariant json) {
    return super.fromJson(json) as List<T>;
  }
}

final class _SetJsonifier<T, L> extends _IterableJsonifier<T, L> {
  const _SetJsonifier(super.itemJsonifier, {super.nullable});

  @override
  String get identifier =>
      "${IterableJsonifier.setIdentifier}${nullable ? "?" : ""}.${itemJsonifier.identifier}";

  @override
  bool canJsonify(object, Jsonifier jsonifier) => object is Set<T>;

  @override
  TypeJsonifier get nullJsonifier => nullable
      ? this
      : _SetJsonifier<T, Set<T>?>(itemJsonifier, nullable: true);

  @override
  Set<T> fromJson(json) => super.fromJson(json).toSet();
}
