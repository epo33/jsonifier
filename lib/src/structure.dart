part of 'jsonifier.dart';

sealed class _Structure {
  TypeJsonifier? forObject(object) {
    _Structure? test<T>(_Structure Function() ifOk) =>
        isA<T>(object) ? ifOk() : null;

    final _Structure? structure = //
        test<JsonMap?>(() => _MapStructure(this)) ??
            test<List?>(() => _ListStructure(this)) ??
            test<Set?>(() => _SetStructure(this)) ??
            test<Iterable?>(() => _IterableStructure(this));
    return structure?.scan(object, jsonifier.typeJsonifiers);
  }

  _Structure(this.parent);

  _Structure.root();

  late final _Structure parent;

  _RootStructure get root => parent.root;

  Jsonifier get jsonifier => root.jsonifier;

  bool isA<V>(object);

  bool isAOrNull<V>(object);

  TypeJsonifier createTypeJsonifier(TypeJsonifier itemJsonifier);

  TypeJsonifier? scan(object, Iterable<TypeJsonifier> jsonifiers) {
    TypeJsonifier? tryJsonifier(TypeJsonifier j) {
      if (j.objectIsA(object, isA)) {
        return createTypeJsonifier(j);
      }
      if (j.objectIsA(object, isAOrNull)) {
        return createTypeJsonifier(j).nullJsonifier;
      }
      return j.nullable ? null : tryJsonifier(j.nullJsonifier);
    }

    for (final j in jsonifiers) {
      final result = tryJsonifier(j);
      if (result != null) return result;
    }
    return null;
  }
}

class _RootStructure extends _Structure {
  _RootStructure(this.jsonifier) : super.root() {
    parent = this;
  }

  @override
  final Jsonifier jsonifier;

  final cache = <Type, TypeJsonifier>{};

  @override
  _RootStructure get root => this;

  @override
  bool isA<V>(object) => object is V;

  @override
  bool isAOrNull<V>(object) => object is V?;

  @override
  TypeJsonifier? forObject(object) {
    var result = cache[object.runtimeType];
    if (result == null) {
      result = super.forObject(object);
      if (result != null) {
        cache[object.runtimeType] = result;
      }
    }
    return result;
  }

  @override
  TypeJsonifier createTypeJsonifier(TypeJsonifier itemJsonifier) =>
      throw UnimplementedError();
}

class _MapStructure extends _Structure {
  _MapStructure(super.parent);

  @override
  bool isA<V>(object) => parent.isA<Map<String, V>>(object);

  @override
  bool isAOrNull<V>(object) => parent.isA<Map<String, V>?>(object);

  @override
  TypeJsonifier createTypeJsonifier(TypeJsonifier itemJsonifier) =>
      itemJsonifier.mapJsonifiers;

  @override
  TypeJsonifier? scan(object, Iterable<TypeJsonifier> jsonifiers) {
    var type = super.scan(object, jsonifiers);
    if (type != null) return type; // Simple Map type
    type = forObject(object);
    return type == null ? MapJsonifier.dynamic() : type.mapJsonifiers;
  }
}

class _IterableStructure<T extends Iterable> extends _Structure {
  _IterableStructure(super.parent);

  @override
  bool isA<V>(object) => parent.isA<Iterable<V>>(object);

  @override
  bool isAOrNull<V>(object) => parent.isA<Iterable<V>?>(object);

  @override
  TypeJsonifier createTypeJsonifier(TypeJsonifier itemJsonifier) =>
      itemJsonifier.jsonifierIterable;

  @override
  TypeJsonifier? scan(object, Iterable<TypeJsonifier> jsonifiers) {
    var type = super.scan(object, jsonifiers);
    if (type != null) return type; // Simple Iterable type
    type = forObject(object);
    return type == null
        ? null
        : isA(object)
            ? createTypeJsonifier(type)
            : createTypeJsonifier(type).nullJsonifier;
  }
}

class _ListStructure extends _IterableStructure<List> {
  _ListStructure(super.parent);

  @override
  bool isA<V>(object) => parent.isA<List<V>>(object);

  @override
  bool isAOrNull<V>(object) => parent.isA<List<V>?>(object);

  @override
  TypeJsonifier createTypeJsonifier(TypeJsonifier itemJsonifier) =>
      itemJsonifier.jsonifierList;
}

class _SetStructure extends _IterableStructure<Set> {
  _SetStructure(super.parent);

  @override
  bool isA<V>(object) => parent.isA<Set<V>>(object);

  @override
  bool isAOrNull<V>(object) => parent.isA<Set<V>?>(object);

  @override
  TypeJsonifier createTypeJsonifier(TypeJsonifier itemJsonifier) =>
      itemJsonifier.jsonifierSet;
}
