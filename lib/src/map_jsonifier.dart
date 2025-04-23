import 'package:jsonifier/jsonifier.dart';
import 'package:meta/meta.dart';

final class MapJsonifier<T> extends TypeJsonifier<Map<String, T>> {
  static const jsonMapIdentifier = "JsonMap";

  static const mapIdentifier = "Map";

  static String mapTypeMarker(Jsonifier jsonifier) =>
      "${jsonifier.reservedStringPrefix}type${jsonifier.reservedStringPrefix}";

  static TypeJsonifier? identifyJsonifier(Map map, Jsonifier jsonifier) {
    if (!map.keys.every((key) => key is String)) return null;
    final type = map[mapTypeMarker(jsonifier)];
    if (type == null) return MapJsonifier.dynamic();
    return jsonifier //
        .typeJsonifiers
        .identifiedBy(type)
        ?.mapJsonifiers;
  }

  const MapJsonifier(
      {required TypeJsonifier<T> this.valueJsonifier, super.nullable});

  @internal
  const MapJsonifier.dynamic({super.nullable}) : valueJsonifier = null;

  final TypeJsonifier<T>? valueJsonifier;

  @override
  String get identifier => valueJsonifier == null
      ? jsonMapIdentifier
      : "$mapIdentifier${nullable ? "?" : ""}.${valueJsonifier!.identifier}";

  @override
  JsonMap fromJson(json) {
    final map = _validMap(json);
    return map.cast<String, T>();
  }

  @override
  TypeJsonifier get nullJsonifier => nullable
      ? this
      : valueJsonifier == null
          ? MapJsonifier.dynamic(nullable: true)
          : MapJsonifier<T>(valueJsonifier: valueJsonifier!, nullable: true);

  @override
  JsonMap toJson(object) => _validMap(object);

  @override
  encode(JsonMap object, Jsonifier jsonifier) {
    final map = object.map(
      (key, value) => MapEntry(key, jsonifier.toJson(value)),
    );
    if (valueJsonifier != null) {
      map[mapTypeMarker(jsonifier)] = valueJsonifier!.identifier;
    }
    return map;
  }

  @override
  decode(JsonMap object, Jsonifier jsonifier) {
    object.remove(mapTypeMarker(jsonifier));
    return object.map(
      (key, value) => MapEntry(key, jsonifier.fromJson(value)),
    );
  }

  static JsonMap _validMap(dynamic map) {
    assert(map is Map && map.keys.every((key) => key is String));
    return (map as Map).cast<String, dynamic>();
  }
}
