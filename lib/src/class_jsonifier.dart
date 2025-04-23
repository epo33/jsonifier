import 'package:jsonifier/jsonifier.dart';

abstract class ClassJsonifier<C extends Object> extends TypeJsonifier<C> {
  const ClassJsonifier({super.nullable});

  static String classTypeMarker(Jsonifier jsonifier) =>
      "${jsonifier.reservedStringPrefix}class${jsonifier.reservedStringPrefix}";

  static TypeJsonifier? identifyJsonifier(Map map, Jsonifier jsonifier) {
    if (!map.keys.every((key) => key is String)) return null;
    final type = map[classTypeMarker(jsonifier)];
    if (type == null) return null;
    return jsonifier //
        .typeJsonifiers
        .whereType<ClassJsonifier>()
        .identifiedBy(type);
  }

  @override
  C fromJson(JsonMap json);

  @override
  JsonMap toJson(C object);

  @override
  encode(JsonMap object, Jsonifier jsonifier) {
    final map = object.map(
      (key, value) => MapEntry(key, jsonifier.toJson(value)),
    );
    map.removeWhere((key, value) => value == null);
    map[classTypeMarker(jsonifier)] = identifier;
    return map;
  }

  @override
  decode(JsonMap object, Jsonifier jsonifier) {
    object.remove(classTypeMarker(jsonifier));
    return object.map(
      (key, value) => MapEntry(key, jsonifier.fromJson(value)),
    );
  }
}
