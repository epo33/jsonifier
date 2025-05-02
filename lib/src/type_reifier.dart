import 'package:jsonifier/jsonifier.dart';

abstract interface class GenericTypeReifier {
  TypeReifier scanGenerics(TypeScanner scanner);
}

class TypeReifier<T extends Object?> {
  const TypeReifier(
    this.baseIdentifier, {
    this.nullable = false,
    this.priority = 0,
  });

  final String baseIdentifier;

  final bool nullable;

  final int priority;

  Type get type => T;

  String get identifier => buildIdentifier(baseIdentifier);

  TypeReifier? scanObjectType(TypeScanner scanner) => scanner.objectIsA<T>()
      ? this
      : scanner.objectIsA<T?>()
          ? nullReifier
          : null;

  TypeReifier get nullReifier => nullable
      ? this
      : TypeReifier<T?>(
          baseIdentifier,
          nullable: true,
          priority: priority,
        );

  TypeReifier getReifierFor(String identifier, Jsonifier jsonifier) =>
      throw StateError("Type reifier for $T doesn't allow generic type.");

  R callWithType<R>(R Function<T1 extends T>() called) => called<T>();

  R callWithOneType<R>(R Function<T1>() called) => called<T>();

  fromDescendant<X extends T>(
    TypeReifier<X> reifier,
    Function<X>() called,
  ) =>
      reifier.callWithType(
        <V extends X>() => called<V>(),
      );

  R callWithTwoTypes<R>(
    R Function<T1, T2>() called,
    TypeReifier second,
  ) =>
      second.callWithOneType<R>(
          <C2>() => callWithOneType<R>(<C1>() => called<C1, C2>()));

  R callWithThreeTypes<R>(
    R Function<T1, T2, T3>() called,
    TypeReifier second,
    TypeReifier third,
  ) =>
      third.callWithTwoTypes<R>(
        <C2, C3>() => callWithOneType<R>(
          <C1>() => called<C1, C2, C3>(),
        ),
        second,
      );

  @override
  String toString() => identifier;

  String buildIdentifier(String baseIdentifier, [String? subType]) =>
      subType == null
          ? nullable
              ? "$baseIdentifier?"
              : baseIdentifier
          : nullable
              ? "$baseIdentifier?.$subType"
              : "$baseIdentifier.$subType";

  @override
  bool operator ==(other) => other is TypeReifier && other.type == type;

  @override
  int get hashCode => type.hashCode;
}
