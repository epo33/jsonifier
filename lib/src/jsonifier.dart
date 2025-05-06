import 'package:collection/collection.dart';

import '../jsonifier.dart';

part 'type_scanner.dart';

class Jsonifier {
  Jsonifier({
    Iterable<TypeJsonifier> typeJsonifiers = const [],
    Iterable<TypeReifier> typeReifiers = const [],
    int? reservedStringPrefixCode,
  }) : reservedStringPrefixCode = reservedStringPrefixCode ?? 0xe000 {
    final jsonifiers = [
      ...TypeJsonifier.baseJsonifiers,
      ...typeJsonifiers,
    ].sortedBy((jsonifier) => jsonifier.identifier);
    _reifiers.addAll(
      [
        ...jsonifiers,
        ...typeReifiers,
      ].sortedBy<num>((reifier) => reifier.priority),
    );
    // Control identifiers unicity.
    final duplicates = _reifiers.groupFoldBy<String, int>(
      (reifier) => reifier.identifier,
      (count, reifier) => (count ?? 0) + 1,
    )..removeWhere((key, value) => value < 2);
    if (duplicates.isNotEmpty) {
      throw StateError(
        "Duplicate identifier${duplicates.length > 1 ? "s" : ""} : ${duplicates.values.join(", ")}.",
      );
    }
    // Control identifier validity.
    final invalidIdentifiers =
        _reifiers.map((reifier) => reifier.identifier).where(
              (identifier) =>
                  identifier.contains(".") ||
                  identifier.contains(reservedStringPrefix),
            );
    if (invalidIdentifiers.isNotEmpty) {
      throw StateError(
        "Invalid identifier${invalidIdentifiers.length > 1 ? "s" : ""} : ${duplicates.values.join(", ")}.",
      );
    }
    // Register typeJsonifiers by descending priority : prefer subclass to ancestor class.
    _jsonifiers.addAll(
      jsonifiers.sortedBy<num>((jsonifier) => -jsonifier.priority),
    );
    _reifiersByNames.addEntries(
      _reifiers.map((reifier) => MapEntry(reifier.baseIdentifier, reifier)),
    );
    _reifiersByType.addEntries(
      _reifiersByNames.values.map((reifier) => MapEntry(reifier.type, reifier)),
    );
  }

  final int reservedStringPrefixCode;

  String get reservedStringPrefix =>
      String.fromCharCode(reservedStringPrefixCode);

  Iterable<TypeJsonifier> get typeJsonifiers => _jsonifiers;

  R getReifierFor<R extends TypeReifier?>(String identifier) {
    TypeReifier? scan() {
      final types = identifier.split(".");
      if (types.isEmpty) return null;
      var type = types.first;
      var nullable = type.endsWith("?");
      if (nullable) type = type.substring(0, type.length - 1);
      var reifier = typeReifierForIdentifier(type);
      if (nullable) reifier = reifier.nullReifier;
      return types.length > 1
          ? reifier.getReifierFor(types.skip(1).join("."), this)
          : reifier;
    }

    final result = scan();
    if (result is! R) {
      throw StateError(
          "Invalid TypeReifier : found ${result.runtimeType}, expected $R");
    }
    return result;
  }

  T? jsonifierFor<T extends TypeJsonifier>(object, {bool mustExists = true}) {
    final scanner = TypeScanner(_reifiers, object);
    final result = scanner._scanRoot(_reifierCache);
    if (result is T || !mustExists) return result as T;
    throw "No jsonifier found for type ${object.runtimeType}";
  }

  Iterable<TypeReifier> get typeReifier => _reifiersByNames.values;

  TypeReifier typeReifierForIdentifier(String identifier) {
    final reifier = _reifiersByNames[identifier];
    if (reifier == null) {
      throw "No reifier found for '$identifier'.";
    }
    return reifier;
  }

  TypeReifier typeReifierForType(Type type) {
    final reifier = _reifiersByType[type];
    if (reifier == null) {
      throw "No reifier found for type $type.";
    }
    return reifier;
  }

  dynamic fromJson<T>(json) {
    if (json == null) return null;

    bool isJsonified(object) =>
        object is String && object.startsWith(reservedStringPrefix);

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
      jsonifier ??= _jsonifiers.firstWhereOrNull(
        (jsonifier) => jsonifier.canJsonify(json, this),
      );
    }
    if (jsonifier == null) {
      throw "No jsonifier found for type ${json.runtimeType}";
    }
    jsonifier = jsonifier.typeJsonifierFor(json, this);
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

    if (object == null) return null;
    if (object is String && alreadyJsonified(object)) return object;
    if (object is Map && object.keys.any(alreadyJsonified)) return object;
    if (object is Iterable && alreadyJsonified(object.lastOrNull)) {
      return object;
    }
    final jsonifier = TypeScanner(_reifiers, object)._scanRoot(_reifierCache);
    if (jsonifier == null || jsonifier is! TypeJsonifier) {
      throw "No jsonifier found for type ${object.runtimeType}";
    }
    final json = jsonifier.toJson(object);
    return jsonifier.encode(json, this);
  }

  final _jsonifiers = <TypeJsonifier>{};
  final _reifiers = <TypeReifier>[];
  final _reifiersByNames = <String, TypeReifier>{};
  final _reifiersByType = <Type, TypeReifier>{};
  final _reifierCache = <Type, TypeReifier>{};
}
