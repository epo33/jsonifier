import 'package:jsonifier/jsonifier.dart';

final class MapJsonifier<T, M extends Map<String, dynamic>?>
    extends TypeJsonifier<M> with OneGenericTypeJsonifierMixin<M> {
  static const jsonMapIdentifier = "JsonMap";

  static const mapIdentifier = "Map";

  static const jsonMapJsonifier = MapJsonifier._();

  static String mapTypeMarker(Jsonifier jsonifier) =>
      "${jsonifier.reservedStringPrefix}type${jsonifier.reservedStringPrefix}";

  static TypeJsonifier? identifyJsonifier(Map map, Jsonifier jsonifier) {
    if (!map.keys.every((key) => key is String)) return null;
    final type = map[mapTypeMarker(jsonifier)];
    final reifier = type == null //
        ? null
        : jsonifier.getReifierFor<TypeReifier>(type);
    return reifier == null
        ? MapJsonifier<dynamic, Map<String, dynamic>>._()
        : reifier.callWithOneType(
            <V>() => MapJsonifier<V, Map<String, V>>._(genericReifier: reifier),
          );
  }

  const MapJsonifier._({
    this.genericReifier,
    super.nullable,
  }) : super(mapIdentifier);

  @override
  final TypeReifier? genericReifier;

  @override
  JsonMap fromJson(json) {
    final map = _validMap(json);
    return Map<String, T>.from(map);
  }

  @override
  JsonMap toJson(object) => _validMap(object);

  @override
  encode(JsonMap object, Jsonifier jsonifier) {
    final map = object.map(
      (key, value) => MapEntry(key, jsonifier.toJson(value)),
    );
    map[mapTypeMarker(jsonifier)] = genericReifier?.identifier;
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

  @override
  TypeJsonifier buildJsonifier<V>({
    required bool nullable,
    TypeReifier<V>? reifier,
  }) =>
      nullable
          ? MapJsonifier<V, Map<String, V>?>._(
              nullable: nullable,
              genericReifier: reifier,
            )
          : MapJsonifier<V, Map<String, V>>._(
              nullable: nullable,
              genericReifier: reifier,
            );

  @override
  ObjectIsA buildObjectIsA<V>(TypeScanner scanner, {required bool nullable}) =>
      nullable
          ? <K>() => scanner.objectIsA<Map<String, K>?>()
          : <K>() => scanner.objectIsA<Map<String, K>>();
}
