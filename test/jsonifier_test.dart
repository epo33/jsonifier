import 'dart:math';

import 'package:collection/collection.dart';
import 'package:jsonifier/jsonifier.dart';
import 'package:test/test.dart';

import 'test_class.dart';

enum TestEnum1 {
  one,
  two,
}

enum TestEnum2 {
  three,
  four,
}

void main() {
  void testJsonnify<V, T>(
    V object, [
    bool Function(V to, V from)? testEquality,
  ]) {
    final jsonifier = Jsonifier(
      jsonifiers: [
        EnumJsonifier<TestEnum1>(
          identifier: "TestEnum1",
          values: TestEnum1.values,
        ),
        EnumJsonifier<TestEnum2>(
          identifier: "TestEnum2",
          values: TestEnum2.values,
        ),
        TestJsonifier(),
      ],
    );
    final json = jsonifier.toJson(object);
    expect(json is T, isTrue);
    final value = jsonifier.fromJson(json);
    expect(value is V, isTrue);
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
    "Enum jsonifier",
    () {
      testJsonnify(TestEnum1.one);
      testJsonnify(TestEnum2.three);
    },
  );
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
    () => testJsonnify<JsonMap, JsonMap>(
      {"1": "1"},
      MapEquality().equals,
    ),
  );
  test(
    "Structure jsonifier",
    () => testJsonnify(
      {
        "1": [
          {1, 2, 3},
          {4, 5, 6},
          null,
        ],
      },
      (_, __) => true,
    ),
  );
  test(
    "Class jsonifier",
    () => testJsonnify(
      TestJson(
        "s1",
        null,
        1,
        2,
        pi,
        null,
        true,
        false,
        ["l1"],
        null,
        {"m1": "m1"},
        null,
        DateTime.now(),
        null,
      ),
    ),
  );
}
