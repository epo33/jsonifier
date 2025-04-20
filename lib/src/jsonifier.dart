import 'package:collection/collection.dart';
import 'package:jsonifier/src/base_types.dart';
import 'package:jsonifier/src/iterable_jsonifier.dart';

import '../jsonifier.dart';

class Jsonifier {
  Jsonifier({
    Iterable<TypeJsonifier> jsonifiers = const [],
    this.stringEncodedMark = 0xe000,
  })  : _jsonifiers = <TypeJsonifier>[
          ...TypeJsonifier.baseJsonifiers,
          ...jsonifiers,
        ],
        _jsonifierMap = Map.fromEntries(
          <TypeJsonifier>{
            ...TypeJsonifier.baseJsonifiers,
            ...jsonifiers,
          }.map((jsonifier) => MapEntry(jsonifier.identifier, jsonifier)),
        ) {
    final invalid = _jsonifiers
        .where((j) => j.identifier.isEmpty || j.identifier.contains("."))
        .map((j) => "${j.runtimeType}(${j.identifier})")
        .toList();
    if (invalid.isNotEmpty) {
      throw "TypeJsonifier with invalid identifiers : ${invalid.join(", ")}";
    }
  }

  final int stringEncodedMark;

  TypeJsonifier jsonifierFor(object) {
    if (object == null) return BaseTypeJsonifier.nullJsonfier;
    if (object is Iterable) {
      return _iterableJsonifierToJson(object, _jsonifiers);
    }
    if (object is Map) {
      return MapJsonifier.mapJsonifier(object, this) ?? (throw "Invalid map.");
    }
    final jsonifier = _jsonifiers.firstWhereOrNull(
          (jsonifier) => jsonifier.canJsonify(object, this),
        ) ??
        _jsonifiers.nullJsonifier.firstWhereOrNull(
          (jsonifier) => jsonifier.canJsonify(object, this),
        );
    if (jsonifier == null) {
      throw "No jsonifier found for type ${object.runtimeType}";
    }
    return jsonifier;
  }

  TypeJsonifier identified(String identifier) {
    final types = identifier.split(".");
    var type = types.removeLast();
    var nullable = type.endsWith("?");
    if (nullable) type = type.substring(0, type.length - 1);
    var last = _jsonifierMap[type];
    if (last == null) {
      throw "No jsonifier found for type $type";
    }
    if (nullable) last = last.nullJsonifier;
    while (types.isNotEmpty) {
      type = types.removeLast();
      nullable = type.endsWith("?");
      if (nullable) type = type.substring(0, type.length - 1);
      last = switch (type) {
        SetJsonifier.setIdentifier => last!.setJsonifiers(this),
        ListJsonifier.listIdentifier => last!.listJsonifiers(this),
        _ => throw "Invalid type: $type",
      };
      if (nullable) last = last.nullJsonifier;
    }
    return last!;
  }

  dynamic fromJson<T>(json) {
    if (json == null) return null;
    if (json is Map) {
      final jsonifier = MapJsonifier.mapJsonifier(json, this);
      if (jsonifier == null) {
        throw "No jsonifier found for type ${json.runtimeType}";
      }
      return jsonifier.fromJson(json, this);
    }
    if (json is Iterable) {
      return _iterableJsonifierFromJson(json).fromJson(json, this);
    }
    final jsonifier = (json is String
            ? StringEncodeJsonifier.fromEncodededString(
                json,
                UnmodifiableMapView(_jsonifierMap),
              )
            : null) ??
        _jsonifierMap //
            .values
            .firstWhereOrNull((jsonifier) => jsonifier.canJsonify(json, this));
    if (jsonifier == null) {
      throw "No jsonifier found for type ${json.runtimeType}";
    }
    return jsonifier.fromJson(json, this);
  }

  dynamic toJson(object) {
    if (object == null) {
      return null;
    } else if (object is Map) {
      final jsonifier = MapJsonifier();
      return jsonifier.toJson(object, this);
    } else if (object is Iterable) {
      final jsonifier = _iterableJsonifierToJson(object, _jsonifiers);
      return jsonifier.toJson(object, this);
    } else {
      final jsonifier = jsonifierFor(object);
      final json = jsonifier.toJson(object, this);
      if (json is Map) MapJsonifier.addClassMarker(json, jsonifier);
      return json;
    }
  }

  IterableJsonifier _iterableJsonifierToJson(
    Iterable iterable,
    Iterable<TypeJsonifier> jsonifiers,
  ) {
    jsonifiers = [
      ...jsonifiers,
      ...jsonifiers.mapJsonifiers(this),
      ...jsonifiers.associatedJsonifiers(this),
    ];
    final jsonifier = jsonifiers.iterableJsonifiers(this).firstWhereOrNull(
              (jsonifier) => jsonifier.canJsonify(iterable, this),
            ) ??
        jsonifiers.nullJsonifier.iterableJsonifiers(this).firstWhereOrNull(
              (jsonifier) => jsonifier.canJsonify(iterable, this),
            );
    if (jsonifier != null) return jsonifier;
    if (iterable is Iterable<Iterable>) {
      return _iterableJsonifierToJson(
          iterable, jsonifiers.iterableJsonifiers(this));
    }
    throw "No jsonifier found for type ${iterable.runtimeType}.";
  }

  TypeJsonifier _iterableJsonifierFromJson(Iterable iterable) {
    if (iterable.isEmpty) {
      throw "Can't fix type of an empty iterable.";
    }
    final type = iterable.last;
    if (type is! String) {
      throw "Last element of iterable must be a string.";
    }
    return identified(type);
  }

  final Map<String, TypeJsonifier> _jsonifierMap;
  final Iterable<TypeJsonifier> _jsonifiers;
}
