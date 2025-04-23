part of 'jsonifier.dart';

extension JsonifiersExtenstion on Iterable<TypeJsonifier> {
  Map<String, TypeJsonifier> get asJsonifierMap => Map.fromEntries(
        map((jsonifier) => MapEntry(jsonifier.identifier, jsonifier)),
      );

  TypeJsonifier? identifiedBy(String identifier) =>
      asJsonifierMap.identifiedBy(identifier);

  TypeJsonifier? firstJsonifierFor(object, Jsonifier jsonifier) =>
      firstWhereOrNull((j) => j.canJsonify(object, jsonifier));

  TypeJsonifier? jsonifierFor(object, Jsonifier jsonifier) => object == null
      ? BaseTypeJsonifier.nullJsonfier
      : firstJsonifierFor(object, jsonifier) ??
          jsonifier._rootStructure.forObject(object);
}

extension JsonifiersMapExtention on Map<String, TypeJsonifier> {
  TypeJsonifier identifiedBy(String identifier) {
    final types = identifier.split(".");
    var type = types.removeLast();
    var nullable = type.endsWith("?");
    if (nullable) type = type.substring(0, type.length - 1);
    var last = type == MapJsonifier.jsonMapIdentifier
        ? MapJsonifier.dynamic()
        : this[type];
    if (last == null) {
      throw "No jsonifier found for type $type";
    }
    if (nullable) last = last.nullJsonifier;
    while (types.isNotEmpty) {
      type = types.removeLast();
      nullable = type.endsWith("?");
      if (nullable) type = type.substring(0, type.length - 1);
      last = switch (type) {
        IterableJsonifier.iterableIdentifier => last!.jsonifierIterable,
        IterableJsonifier.setIdentifier => last!.jsonifierSet,
        IterableJsonifier.listIdentifier => last!.jsonifierList,
        MapJsonifier.mapIdentifier => last!.mapJsonifiers,
        _ => throw "Invalid type: $type",
      };
      if (nullable) last = last.nullJsonifier;
    }
    return last!;
  }

  TypeJsonifier? jsonifierFor(object, Jsonifier jsonifier) =>
      values.jsonifierFor(object, jsonifier);
}
