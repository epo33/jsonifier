import 'package:jsonifier/jsonifier.dart';

class Generic<T extends num> {
  Generic(this.value);

  final T value;

  @override
  bool operator ==(other) => other is Generic && other.value == value;
}

class GenericToJson<T extends num> extends GenericClass1<Generic, T> {
  GenericToJson() : super("Generic");

  @override
  Generic<num> fromJson<T1 extends T>(JsonMap jsonMap) =>
      Generic<T>(jsonMap["value"]);

  @override
  JsonMap toJson(Generic<num> object) => {
        "value": object.value,
      };

  @override
  GenericClass1<Generic<num>, T1> boundGenericClass<T1 extends T>() =>
      GenericToJson<T1>();

  @override
  Type boundedType<T1 extends T>() => Generic<T1>;

  @override
  bool objectIsA<T1 extends T>(object, bool Function<V>() isA) =>
      isA<Generic<T1>>();
}
