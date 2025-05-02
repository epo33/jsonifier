part of 'generic_class_jsonifier.dart';

abstract class GenericClass<C extends Object, Bound1, Bound2, Bound3> {
  static Never invalidBoundIndex(int index) => throw StateError(
        "GenericClass can't have $index generic type${index > 1 ? "s" : ""}",
      );

  const GenericClass(
    this.baseIdentifier, {
    required this.nGenericTypes,
    this.priority = 0,
  });

  final String baseIdentifier;

  final int nGenericTypes;

  final int priority;

  GenericClassJsonifier<C> get typeJsonifier => GenericClassJsonifier<C>(
        baseIdentifier,
        generic: this,
        priority: priority,
      );

  JsonMap toJson(C object);

  C _fromJson<T1 extends Bound1, T2 extends Bound2, T3 extends Bound3>(
    JsonMap json,
  );

  GenericClass<C, Bound1, Bound2, Bound3> _boundedBenericClass<
      T1 extends Bound1, //
      T2 extends Bound2,
      T3 extends Bound3>();

  bool _objectIs<
      T1 extends Bound1, //
      T2 extends Bound2,
      T3 extends Bound3>(
    TypeScanner scanner,
  );

  GenericClass<
      C, //
      dynamic,
      dynamic,
      dynamic> _getBoundedGeneric(TypeScanner scanner) {
    final reifiers1 = _forBound<Bound1>(
      scanner,
      1,
      <B extends Bound1>() => _objectIs<B, Bound2, Bound3>(scanner),
    );
    final reifiers2 = _forBound<Bound2>(
      scanner,
      2,
      <B extends Bound2>() => _objectIs<Bound1, B, Bound3>(scanner),
    );
    final reifiers3 = _forBound<Bound3>(
      scanner,
      3,
      <B extends Bound3>() => _objectIs<Bound1, Bound2, B>(scanner),
    );
    return reifiers1.callWithType(
      <T1 extends Bound1>() => reifiers2.callWithType(
        <T2 extends Bound2>() => reifiers3.callWithType(
          <T3 extends Bound3>() => _boundedBenericClass<T1, T2, T3>(),
        ),
      ),
    );
  }

  TypeReifier<Bound> _forBound<Bound>(
    TypeScanner scanner,
    int index,
    bool Function<V extends Bound>() testIs,
  ) {
    if (index > nGenericTypes) return TypeReifier<Bound>("");
    final reifier = scanner //
        .typeReifiers
        .whereType<TypeReifier<Bound>>()
        .firstWhereOrNull(
          (reifier) => reifier.callWithType(
            <V extends Bound>() => testIs<V>(),
          ),
        );
    if (reifier == null) {
      throw StateError("No TypeReifier found for generic type $Bound of $C.");
    }
    return reifier;
  }

}

abstract class GenericClass1<C extends Object, Bound1>
    extends GenericClass<C, Bound1, Object, Object> {
  const GenericClass1(super.baseIdentifier) : super(nGenericTypes: 1);

  C fromJson<T1 extends Bound1>(JsonMap jsonMap);

  GenericClass1<C, T1> boundGenericClass<T1 extends Bound1>();

  bool objectIsA<T1 extends Bound1>(object, bool Function<V>() isA);

  Type boundedType<T1 extends Bound1>();

  @override
  C _fromJson<T1 extends Bound1, T2 extends Object, T3 extends Object>(
          JsonMap json) =>
      fromJson<T1>(json);

  GenericClass<C, Bound1, Object, Object> _boundedBenericClass<
          T1 extends Bound1, //
          T2 extends Object,
          T3 extends Object>() =>
      boundGenericClass<T1>();

  bool _objectIsA<
      T1 extends Bound1, //
      T2 extends Object,
      T3 extends Object>(object, bool Function<V>() isA);
}

abstract class GenericClass2<C extends Object, Bound1, Bound2>
    extends GenericClass<C, Bound1, Bound2, Object> {
  const GenericClass2(super.baseIdentifier) : super(nGenericTypes: 2);

  C fromJson<T1 extends Bound1, T2 extends Bound2>(JsonMap json);

  GenericClass2<C, T1, T2> bound<
      T1 extends Bound1, //
      T2 extends Bound2>();

  @override
  C _fromJson<T1 extends Bound1, T2 extends Bound2, T3 extends Object>(
          JsonMap json) =>
      fromJson<T1, T2>(json);

  GenericClass<C, Bound1, Bound2, Object> _boundedBenericClass<
          T1 extends Bound1, //
          T2 extends Bound2,
          T3 extends Object>() =>
      bound<T1, T2>();
}

abstract class GenericClass3<C extends Object, Bound1, Bound2, Bound3>
    extends GenericClass<C, Bound1, Bound2, Bound3> {
  const GenericClass3(super.baseIdentifier) : super(nGenericTypes: 3);

  C fromJson<T1 extends Bound1, T2 extends Bound2, T3 extends Bound3>(
    JsonMap json,
  );

  GenericClass3<C, T1, T2, T3> bound<
      T1 extends Bound1, //
      T2 extends Bound2,
      T3 extends Bound3>();

  bool objectIsA<
      T1 extends Bound1, //
      T2 extends Bound2,
      T3 extends Bound3>(object, bool Function<V>() isA);

  @override
  C _fromJson<T1 extends Bound1, T2 extends Bound2, T3 extends Bound3>(
    JsonMap json,
  ) =>
      fromJson<T1, T2, T3>(json);

  GenericClass<C, Bound1, Bound2, Bound3> _boundedBenericClass<
          T1 extends Bound1, //
          T2 extends Bound2,
          T3 extends Bound3>() =>
      bound<T1, T2, T3>();

  bool _objectIsA<
          T1 extends Bound1, //
          T2 extends Bound2,
          T3 extends Bound3>(object, bool Function<V>() isA) =>
      objectIsA<T1, T2, T3>(object, isA);
}
