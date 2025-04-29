import 'package:jsonifier/jsonifier.dart';

abstract class ClassJsonifier<C extends Object> extends TypeJsonifier<C> {
  const ClassJsonifier({super.nullable, int priority = 0})
      : _priority = priority;

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
  bool canJsonify(object, Jsonifier jsonifier) => object.runtimeType == C;

  @override
  int get priority => _priority;

  @override
  C fromJson(JsonMap json);

  @override
  JsonMap toJson(C object);

  @override
  encode(JsonMap object, Jsonifier jsonifier, C source) {
    final map = object.map(
      (key, value) => MapEntry(key, jsonifier.toJson(value)),
    );
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

  final int _priority;
}
