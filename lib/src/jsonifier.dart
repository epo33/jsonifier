import 'package:collection/collection.dart';
import 'package:jsonifier/src/base_types.dart';
import 'package:jsonifier/src/iterable_jsonifier.dart';

import '../jsonifier.dart';
part 'structure.dart';
part 'extensions.dart';

class Jsonifier {
  Jsonifier({
    Iterable<TypeJsonifier> jsonifiers = const [],
    this.reservedStringPrefixCode = 0xe000,
  }) {
    _rootStructure = _RootStructure(this);
    _jsonifiers
      ..addAll(TypeJsonifier.baseJsonifiers)
      ..addAll(jsonifiers);
    final invalid = _jsonifiers
        .where((j) => j.identifier.isEmpty || j.identifier.contains("."))
        .map((j) => "${j.runtimeType}(${j.identifier})")
        .toList();
    if (invalid.isNotEmpty) {
      throw "TypeJsonifier with invalid identifiers : ${invalid.join(", ")}";
    }
  }

  final int reservedStringPrefixCode;

  String get reservedStringPrefix =>
      String.fromCharCode(reservedStringPrefixCode);

  Iterable<TypeJsonifier> get typeJsonifiers => _jsonifiers;

  dynamic fromJson<T>(json) {
    bool isJsonified(object) =>
        object is String && object.startsWith(reservedStringPrefix);

    if (json == null) return null;
    if (json is! String &&
        json is! num &&
        json is! bool &&
        json is! Iterable &&
        json is! Map) {
      return json;
    }
    TypeJsonifier? jsonifier;
    if (json is Map) {
      if (!json.keys.any(isJsonified)) return json;
      jsonifier = ClassJsonifier.identifyJsonifier(json, this) ??
          MapJsonifier.identifyJsonifier(json, this);
    } else if (json is Iterable) {
      if (!isJsonified(json.lastOrNull)) return json;
      jsonifier = IterableJsonifier.identifyJsonifier(json, this);
    } else {
      if (json is String) {
        jsonifier = StringEncodeJsonifier.fromEncodededString(json, this);
      }
      jsonifier ??= typeJsonifiers.firstJsonifierFor(json, this);
    }
    if (jsonifier == null) {
      throw "No jsonifier found for type ${json.runtimeType}";
    }
    final result = jsonifier.fromJson(jsonifier.decode(json, this));
    if (result is! T) {
      throw "Invalid type ${result.runtimeType}. Expected $T.";
    }
    return result;
  }

  dynamic toJson(object) {
    // toJson MUST be idempotent ie toJson(object) == toJson(toJson(object)).
    bool alreadyJsonified(key) =>
        key is String && key.startsWith(reservedStringPrefix);

    if (object is String && alreadyJsonified(object)) return object;
    if (object is Map && object.keys.any(alreadyJsonified)) return object;
    if (object is Iterable && alreadyJsonified(object.lastOrNull)) {
      return object;
    }
    final jsonifier = typeJsonifiers.jsonifierFor(object, this);
    if (jsonifier == null) {
      throw "No jsonifier found for type ${object.runtimeType}";
    }
    final json = jsonifier.toJson(object);
    return jsonifier.encode(json, this);
  }

  final _jsonifiers = <TypeJsonifier>{};
  late final _RootStructure _rootStructure;
}
