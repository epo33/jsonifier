import 'package:jsonifier/jsonifier.dart';
import 'package:meta/meta.dart';

abstract class StringEncodeJsonifier<T> extends TypeJsonifier<T> {
  static const int prefix = 0xe000;

  static String get stringPrefix => String.fromCharCode(prefix);

  const StringEncodeJsonifier({super.nullable});

  static bool isStringEncoding(String s) {
    final runes = s.runes;
    if (runes.isEmpty) return false;
    return runes.first == prefix;
  }

  static StringEncodeJsonifier? fromEncodededString(
    String s,
    Map<String, TypeJsonifier> jsonifiers,
  ) {
    if (!isStringEncoding(s)) return null;
    final parts = s.split(".");
    if (parts.length < 3) return null;
    final identifier = parts[1];
    final jsonifier = jsonifiers[identifier];
    return jsonifier as StringEncodeJsonifier;
  }

  static bool isPrivateUnicodePoint(int codePoint) =>
      (codePoint >= 0xe000 && codePoint <= 0xf8ff) ||
      (codePoint >= 0xf0000 && codePoint <= 0xffffd) ||
      (codePoint >= 0x100000 && codePoint <= 0x10fffd);

  @override
  @nonVirtual
  dynamic fromJson(json, Jsonifier jsonifier) {
    assert(isStringEncoding(json));
    final parts = (json as String).split(".");
    assert(
      parts.length >= 3 && parts[0] == stringPrefix && parts[1] == identifier,
    );
    return decodeValue(parts.skip(2).join("."), jsonifier);
  }

  @override
  @nonVirtual
  toJson(object, Jsonifier jsonifier) {
    final s = encodeValue(object, jsonifier);
    return "$stringPrefix.$identifier.$s";
  }

  T decodeValue(String value, Jsonifier jsonifier);

  String encodeValue(T value, Jsonifier jsonifier);
}
