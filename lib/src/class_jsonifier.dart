import 'package:jsonifier/jsonifier.dart';

abstract class ClassJsonifier<C extends Object> extends TypeJsonifier<C> {
  const ClassJsonifier(super.baseIdentifier, {super.nullable, super.priority});

  static String classTypeMarker(Jsonifier jsonifier) =>
      "${jsonifier.reservedStringPrefix}class${jsonifier.reservedStringPrefix}";

  static TypeJsonifier? identifyJsonifier(Map map, Jsonifier jsonifier) {
    if (!map.keys.every((key) => key is String)) return null;
    final type = map[classTypeMarker(jsonifier)];
    if (type == null) return null;
    return jsonifier.getReifierFor<ClassJsonifier>(type);
  }

  @override
  bool canJsonify(object, Jsonifier jsonifier) =>
      nullable ? object is C? : object is C;

  @override
  C fromJson(JsonMap json);

  @override
  JsonMap toJson(C object);

  @override
  encode(JsonMap object, Jsonifier jsonifier) {
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
}
