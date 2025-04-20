import 'package:jsonifier/src/iterable_jsonifier.dart';

import '../jsonifier.dart';

extension JsonifiersExtenstion on Iterable<TypeJsonifier> {
  Iterable<IterableJsonifier> iterableJsonifiers(Jsonifier jsonifier) =>
      map((j) => j.iterableJsonifiers(jsonifier)).expand((list) => list);

  Iterable<TypeJsonifier> mapJsonifiers(Jsonifier jsonifier) =>
      map((j) => j.mapJsonifiers(jsonifier)).expand((list) => list);

  Iterable<TypeJsonifier> associatedJsonifiers(Jsonifier jsonifier) =>
      map((j) => j.associatedJsonifiers(jsonifier)).expand((list) => list);

  Iterable<TypeJsonifier> get nullJsonifier =>
      map((jsonifier) => jsonifier.nullJsonifier);
}
