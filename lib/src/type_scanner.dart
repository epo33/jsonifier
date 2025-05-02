part of 'jsonifier.dart';

typedef ObjectIsA<T> = bool Function<V extends T>();

class TypeScanner<T> {
  TypeScanner(
    this._reifiers,
    this.object, {
    ObjectIsA<T>? objectIsA,
  }) : objectIsA = objectIsA ?? _rootIsA<T>(object);

  final Object object;

  final ObjectIsA<T> objectIsA;

  Iterable<TypeReifier> get typeReifiers => _reifiers;

  Type get objectType => object.runtimeType;

  TypeReifier<T>? scanObject() {
    for (final reifier in _reifiers.whereType<TypeReifier<T>>()) {
      var type = reifier.callWithOneType<TypeReifier?>(
        <V>() => reifier.scanObjectType(this),
      );
      if (type == null) continue;
      if (type is GenericTypeReifier) {
        type = (type as GenericTypeReifier).scanGenerics(this);
      }
      return type as TypeReifier<T>;
    }
    return null;
  }

  TypeReifier? _scanRoot(Map<Type, TypeReifier> cache) {
    if (cache.containsKey(object.runtimeType)) return cache[object.runtimeType];
    final result = scanObject();
    if (result != null) cache[object.runtimeType] = result;
    return result;
  }

  TypeScanner<E> withObjectIsA<E>(ObjectIsA<E> objectIsA) =>
      TypeScanner<E>(_reifiers, object, objectIsA: objectIsA);

  final Iterable<TypeReifier> _reifiers;
}

ObjectIsA<T> _rootIsA<T>(object) => <V extends T>() => object is V;
