import 'package:jsonifier/jsonifier.dart';

class Generic<T extends num> {
  Generic(this.value);

  final T value;

  @override
  bool operator ==(other) => other is Generic && other.value == value;
}

class GenericToJson extends GenericClass1<Generic, num> {
  @override
  Generic<num> fromJson<T extends num>(JsonMap jsonMap) =>
      Generic<T>(jsonMap["value"]);

  @override
  JsonMap toJson(Generic<num> object) => {
        "value": object.value,
      };

  @override
  Iterable typesSignatureOf(Generic<num> object) => [object.value.runtimeType];
}
