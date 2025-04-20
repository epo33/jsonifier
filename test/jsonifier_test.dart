import 'package:collection/collection.dart';
import 'package:jsonifier/jsonifier.dart';
import 'package:test/test.dart';

void main() {
  void testJsonnify<V, T>(
    V object, [
    bool Function(V to, V from)? testEquality,
  ]) {
    final jsonifier = Jsonifier();
    final json = jsonifier.toJson(object);
    expect(json is T, isTrue);
    final value = jsonifier.fromJson(json);
    expect(
      testEquality?.call(object, value) ?? value == object,
      isTrue,
    );
  }

  test("String jsonifier", () => testJsonnify<String, String>("test"));
  test("Int jsonifier", () => testJsonnify<int, int>(2));
  test("Double jsonifier", () => testJsonnify<double, double>(2.0));
  test("Bool jsonifier", () => testJsonnify<bool, bool>(true));
  test("Null jsonifier", () => testJsonnify(null));
  test("DateTime jsonifier", () => testJsonnify(DateTime.now()));
  test("Duration jsonifier", () => testJsonnify(Duration(days: 1)));
  test(
    "List jsonifier",
    () => testJsonnify<List<int>, List>([1, 2, 3], IterableEquality().equals),
  );
  test(
    "Set jsonifier",
    () => testJsonnify<Set<int>, List>({1, 2, 3}, SetEquality().equals),
  );
  test(
    "Map jsonifier",
    () => testJsonnify<Map<String, dynamic>, Map<String, dynamic>>(
      {"1": "1"},
      MapEquality().equals,
    ),
  );
}
