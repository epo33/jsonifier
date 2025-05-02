import 'dart:convert';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:jsonifier/jsonifier.dart';
import 'package:test/test.dart';

import 'test_class.dart';
import 'test_generic.dart';

enum TestEnum1 {
  one,
  two,
}

enum TestEnum2 {
  three,
  four,
}

void main() {
  final jsonifier = Jsonifier(
    typeJsonifiers: [
      EnumJsonifier<TestEnum1>(
        "TestEnum1",
        values: TestEnum1.values,
      ),
      EnumJsonifier<TestEnum2>(
        "TestEnum2",
        values: TestEnum2.values,
      ),
      TestJsonifier(),
      GenericToJson().typeJsonifier,
    ],
  );
  void testJsonnify<V, T>(
    V object, [
    bool Function(V to, V from)? testEquality,
  ]) {
    final json = jsonifier.toJson(object);
    expect(json is T, isTrue, reason: "toJson() doesn't return a $T.");
    expect(jsonifier.toJson(json), json, reason: "toJson isn't idempotent.");
    final value = jsonifier.fromJson(jsonDecode(jsonEncode(json)));
    expect(
      value is V,
      isTrue,
      reason: "fromJson return a ${value.runtimeType}, type $V expected.",
    );
    expect(
      testEquality?.call(object, value) ?? value == object,
      isTrue,
      reason: "fromJson( toJson(value)) != value",
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
  test(
    "Generic class jsonifier",
    () {
      testJsonnify(Generic(3));
      testJsonnify(Generic(3.5));
    },
  );
  test(
    "List of generic class jsonifier",
    () {
      testJsonnify([Generic(3), Generic(4)]);
    },
  );
}
