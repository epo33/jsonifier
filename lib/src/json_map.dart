typedef JsonMap = Map<String, dynamic>;

extension JsonMapExtension on JsonMap {
  T? asA<T>(String key) => _asA<T>(key);
  String? asString(String key) => _asA<String>(key);
  int? asInt(String key) => _asA<int>(key);
  double? asDouble(String key) => _asA<double>(key);
  bool? asBool(String key) => _asA<bool>(key);
  DateTime? asDateTime(String key) => _asA<DateTime>(key);
  Duration? asDuration(String key) => _asA<Duration>(key);
  E? asEnum<E extends Enum>(String key) => _asA<E>(key);
  Iterable<T>? asIterable<T>(String key) => _asA<Iterable<T>>(key);
  List<T>? asList<T>(String key) => _asA<List<T>>(key);
  Set<T>? asSet<T>(String key) => _asA<Set<T>>(key);
  Map<String, T>? asMap<T>(String key) => _asA<Map<String, T>>(key);

  T? _asA<T>(String key) {
    T? checkValue(value) {
      if (value is T?) return value;
      throw "Key '$key' is of type '${value.runtimeType}', expected '$T'.";
    }

    if (!key.contains(".")) {
      final parts = key.split(".");
      Map map = this;
      var done = "";
      for (final part in parts.take(parts.length - 1)) {
        final value = map[part];
        done = done.isEmpty ? part : "$done.$part";
        if (value == null) throw "Key '$done' is null.";
        if (value is! Map) throw "Key '$done' is not a map.";
        map = value;
      }
      return checkValue(this[parts.last]);
    } else {
      return checkValue(this[key]);
    }
  }
}
