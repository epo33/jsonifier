import 'package:jsonifier/jsonifier.dart';

final class MapJsonifier extends TypeJsonifier<Map<String, dynamic>> {
  static TypeJsonifier? mapJsonifier(Map map, Jsonifier jsonifier) {
    if (!map.keys.every((key) => key is String)) return null;
    final mark = StringEncodeJsonifier.stringPrefix;
    final type = map["${mark}type$mark"];
    if (type == null) return MapJsonifier();
    return jsonifier.identified(type);
  }

  static void addClassMarker(Map map, TypeJsonifier jsonifier) {
    if (jsonifier is! ClassJsonifier) {
      throw "Only ClassJsonifier jsonifiers can return maps.";
    }
    map.removeWhere((key, value) => value == null);
    final mark = StringEncodeJsonifier.stringPrefix;
    map["${mark}type$mark"] = jsonifier.identifier;
  }

  const MapJsonifier({super.nullable});

  @override
  String get identifier => "Map${nullable ? "?" : ""}";

  @override
  Map<String, dynamic> fromJson(json, Jsonifier jsonifier) =>
      _validMap(json).map(
        (key, value) => MapEntry(key, jsonifier.fromJson(value)),
      );

  @override
  // TODO: implement nullJsonifier
  TypeJsonifier get nullJsonifier =>
      nullable ? this : MapJsonifier(nullable: true);

  @override
  Map<String, dynamic> toJson(Map object, Jsonifier jsonifier) {
    return _validMap(object).map(
      (key, value) => MapEntry(key, jsonifier.toJson(value)),
    )..removeWhere((key, value) => value == null);
  }

  static Map<String, dynamic> _validMap(dynamic map) {
    assert(map is Map && map.keys.every((key) => key is String));
    return (map as Map).cast<String, dynamic>();
  }
}
