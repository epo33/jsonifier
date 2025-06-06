import 'package:jsonifier/jsonifier.dart';
import 'package:meta/meta.dart';

mixin StringEncodeJsonifier<T> on TypeJsonifier<T> {
  static bool isStringEncoding(String s, Jsonifier jsonifier) {
    final runes = s.runes;
    if (runes.isEmpty) return false;
    return runes.first == jsonifier.reservedStringPrefixCode;
  }

  static StringEncodeJsonifier? fromEncodededString(
    String s,
    Jsonifier jsonifier,
  ) {
    if (!isStringEncoding(s, jsonifier)) return null;
    final parts = s.split(".");
    if (parts.length < 2) return null;
    final identifier = parts[1];
    return jsonifier.getReifierFor<StringEncodeJsonifier>(identifier);
  }

  static bool isPrivateUnicodePoint(int codePoint) =>
      (codePoint >= 0xe000 && codePoint <= 0xf8ff) ||
      (codePoint >= 0xf0000 && codePoint <= 0xffffd) ||
      (codePoint >= 0x100000 && codePoint <= 0x10fffd);

  @override
  T fromJson(String json);

  @override
  String toJson(T object);

  @override
  FromString<T>? get decodeString => fromJson;

  @override
  @internal
  dynamic encode(String object, Jsonifier jsonifier) =>
      "${jsonifier.reservedStringPrefix}.$identifier.$object";

  @override
  @internal
  dynamic decode(String object, Jsonifier jsonifier) {
    final prefix = "${jsonifier.reservedStringPrefix}.$identifier.";
    assert(object.startsWith(prefix));
    return object.substring(prefix.length);
  }
}
