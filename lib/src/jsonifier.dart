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
    if (json == null) return null;
    TypeJsonifier? jsonifier;
    if (json is Map) {
      jsonifier = ClassJsonifier.identifyJsonifier(json, this) ??
          MapJsonifier.identifyJsonifier(json, this);
    } else if (json is Iterable) {
      jsonifier = IterableJsonifier.identifyJsonifier(json, this);
    } else {
      if (json is String) {
        jsonifier = StringEncodeJsonifier.fromEncodededString(json, this);
      }
      assert(
        json is String || json is int || json is double || json is bool,
        "Invalid json type (${json.runtimeType}).",
      );
      jsonifier ??= typeJsonifiers.firstJsonifierFor(json, this);
    }
    if (jsonifier == null) {
      throw "No jsonifier found for type ${json.runtimeType}";
    }
    return jsonifier.fromJson(jsonifier.decode(json, this));
  }

  dynamic toJson(object) {
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
