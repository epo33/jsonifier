import 'package:jsonifier/jsonifier.dart';

sealed class IterableJsonifier<T> extends TypeJsonifier<Iterable<T>> {
  const IterableJsonifier(this.itemJsonifier, {super.nullable});

  final TypeJsonifier itemJsonifier;

  @override
  Iterable<T> fromJson(json, Jsonifier jsonifier) {
    if (json is! Iterable || json.isEmpty) {
      throw "Invalid json for $identifier.";
    }
    final items = json
        .take(json.length - 1) // Ignore type marker
        .map((item) => jsonifier.fromJson(item));
    return items.cast<T>();
  }

  @override
  dynamic toJson(Iterable object, Jsonifier jsonifier) => object //
      .map((item) => jsonifier.toJson(item))
      .cast<dynamic>()
      .toList()
    ..add(identifier);
}

final class ListJsonifier<T> extends IterableJsonifier<T> {
  static const listIdentifier = "List";

  const ListJsonifier(super.itemJsonifier, {super.nullable});

  @override
  String get identifier =>
      "$listIdentifier.${itemJsonifier.identifier}${nullable ? "?" : ""}";

  @override
  bool canJsonify(object, Jsonifier jsonifier) =>
      object is Iterable<T> && object is! Set<T>;

  @override
  TypeJsonifier get nullJsonifier =>
      nullable ? this : ListJsonifier<T?>(itemJsonifier, nullable: true);

  @override
  List<T> fromJson(json, Jsonifier jsonifier) =>
      super.fromJson(json, jsonifier).toList();
}

final class SetJsonifier<T> extends IterableJsonifier<T> {
  static const setIdentifier = "Set";

  const SetJsonifier(super.itemJsonifier, {super.nullable});

  @override
  String get identifier =>
      "$setIdentifier.${itemJsonifier.identifier}${nullable ? "?" : ""}";

  @override
  bool canJsonify(object, Jsonifier jsonifier) => object is Set<T>;

  @override
  TypeJsonifier get nullJsonifier =>
      nullable ? this : SetJsonifier<T?>(itemJsonifier, nullable: true);

  @override
  Set<T> fromJson(json, Jsonifier jsonifier) =>
      super.fromJson(json, jsonifier).toSet();
}
