import 'package:jsonifier/jsonifier.dart';

abstract class ClassJsonifier<C extends Object> extends TypeJsonifier<C> {
  const ClassJsonifier({super.nullable});
}
