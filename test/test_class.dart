import 'package:collection/collection.dart';
import 'package:jsonifier/jsonifier.dart';

class TestJson {
  TestJson(
    this.s1,
    this.s2,
    this.i1,
    this.i2,
    this.d1,
    this.d2,
    this.b1,
    this.b2,
    this.l1,
    this.l2,
    this.m1,
    this.m2,
    this.dt1,
    this.dt2,
  );

  final String s1;
  final String? s2;
  final int i1;
  final int? i2;
  final double d1;
  final double? d2;
  final bool b1;
  final bool? b2;
  final List<String> l1;
  final List<String>? l2;
  final Map<String, String> m1;
  final Map<String, String>? m2;
  final DateTime dt1;
  final DateTime? dt2;

  @override
  bool operator ==(other) =>
      other is TestJson &&
      s1 == other.s1 &&
      s2 == other.s2 &&
      i1 == other.i1 &&
      i2 == other.i2 &&
      d1 == other.d1 &&
      d2 == other.d2 &&
      b1 == other.b1 &&
      b2 == other.b2 &&
      IterableEquality().equals(l1, other.l1) &&
      dt1 == other.dt1 &&
      dt2 == other.dt2;

  @override
  int get hashCode =>
      Object.hashAll([s1, s2, i1, i2, d1, d2, b1, b2, l1, dt1, dt2]);
}

class TestJsonifier extends ClassJsonifier<TestJson> {
  const TestJsonifier({
    super.nullable,
  });

  @override
  String get identifier => "TestJson";

  @override
  TypeJsonifier get nullJsonifier => TestJsonifier(nullable: true);

  @override
  TestJson fromJson(JsonMap json) {
    return TestJson(
      json.asString("s1")!,
      json.asString("s2"),
      json.asInt("i1")!,
      json.asInt("i2"),
      json.asDouble("d1")!,
      json.asDouble("d2"),
      json.asBool("b1")!,
      json.asBool("b2"),
      json.asList<String>("l1")!,
      json.asList<String>("l2"),
      json.asMap<String>("m1")!,
      json.asMap<String>("m2"),
      json.asDateTime("dt1")!,
      json.asDateTime("dt2"),
    );
  }

  @override
  Map<String, dynamic> toJson(TestJson object) {
    return {
      "s1": object.s1,
      "s2": object.s2,
      "i1": object.i1,
      "i2": object.i2,
      "d1": object.d1,
      "d2": object.d2,
      "b1": object.b1,
      "b2": object.b2,
      "l1": object.l1,
      "l2": object.l2,
      "m1": object.m1,
      "m2": object.m2,
      "dt1": object.dt1,
      "dt2": object.dt2,
    };
  }
}
