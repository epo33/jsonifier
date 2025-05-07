import 'package:jsonifier/jsonifier.dart';
import 'package:jsonifier/src/generics.dart';

sealed class IterableJsonifier<T, L> extends TypeJsonifier<L> {
  static const listIdentifier = "List";
  static const setIdentifier = "Set";

  static const listJsonifier = _ListJsonifier<dynamic, Iterable>(null);

  static const setJsonifier = _SetJsonifier<dynamic, Set>(null);

  static TypeJsonifier? identifyJsonifier(
    Iterable iterable,
    Jsonifier jsonifier,
  ) {
    if (iterable.isEmpty) return null;
    final type = iterable.last;
    if (type is! String) return null;
    assert(type.startsWith(jsonifier.reservedStringPrefix));
    return jsonifier.getReifierFor<IterableJsonifier>(type.substring(1));
  }

  const IterableJsonifier(
    super.baseIdentifier, {
    super.nullable,
    super.priority,
  });
}

abstract class _IterableJsonifier<T, L> extends IterableJsonifier<T, L>
    with OneGenericTypeJsonifierMixin<L> {
  const _IterableJsonifier(
    super.baseIdentifier,
    this.genericReifier, {
    super.nullable,
    super.priority,
  });

  @override
  final TypeReifier<T>? genericReifier;

  @override
  String get identifier => buildIdentifier(
        baseIdentifier,
        genericReifier?.identifier,
      );

  @override
  Iterable<T> fromJson(json) {
    if (json is! Iterable) {
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
      ..add("${jsonifier.reservedStringPrefix}$identifier");
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

// All iterable except Set (because of a lower priority)
final class _ListJsonifier<T, L extends Iterable?>
    extends _IterableJsonifier<T, L> {
  const _ListJsonifier(TypeReifier<T>? itemReifier, {super.nullable})
      : super(IterableJsonifier.listIdentifier, itemReifier, priority: 0);

  @override
  List<T> fromJson(covariant json) {
    return super.fromJson(json) as List<T>;
  }

  @override
  TypeJsonifier buildJsonifier<V>({
    required bool nullable,
    TypeReifier<V>? reifier,
  }) =>
      nullable
          ? _ListJsonifier<V, Iterable<V>?>(reifier, nullable: nullable)
          : _ListJsonifier<V, Iterable<V>>(reifier, nullable: nullable);

  @override
  ObjectIsA buildObjectIsA<V>(TypeScanner scanner, {required bool nullable}) =>
      nullable
          ? <K>() => scanner.objectIsA<Iterable<K>?>()
          : <K>() => scanner.objectIsA<Iterable<K>>();
}

// Priority must be set higher than _ListJsonifier
final class _SetJsonifier<T, S extends Set?> extends _IterableJsonifier<T, S> {
  const _SetJsonifier(TypeReifier<T>? itemReifier, {super.nullable})
      : super(IterableJsonifier.setIdentifier, itemReifier, priority: 1);

  @override
  Set<T> fromJson(json) => super.fromJson(json).toSet();

  @override
  TypeJsonifier buildJsonifier<V>({
    required bool nullable,
    TypeReifier<V>? reifier,
  }) =>
      nullable
          ? _SetJsonifier<V, Set<V>?>(reifier, nullable: nullable)
          : _SetJsonifier<V, Set<V>>(reifier, nullable: nullable);

  @override
  ObjectIsA buildObjectIsA<V>(TypeScanner scanner, {required bool nullable}) =>
      nullable
          ? <K>() => scanner.objectIsA<Set<K>?>()
          : <K>() => scanner.objectIsA<Set<K>>();
}
