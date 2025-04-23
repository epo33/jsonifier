Tools to easily jsonify (fromJson/toJson) objects.

#Usage
Instanciate [Jsonifier]`(jsonifiers:[...])` class and use its methods [Jsonifier.fromJson] and [Jsonifier.toJson]. [Jsonifier] can serialize this types :
* Scalar Json types : null, String, int, double, bool. 
* Dart bases types : DateTime, Duration.
* Any type covered by [TypeJsonifier]s provided in the `jsonifiers` parameter of the contructor.
* Structured types : Map<String, T>, List<T>, Set<T> and Iterable<T> where T is any of 
types enumerated here.
* Any T? where T is any of the preceding types or combination (eg. Set<int?>?, Iterable<String?>, ...).

#How to serialize Enum (or types referencing enums).
To serialize enum types, provide the `jsonifiers` parameter of the [Jsonifier]
constructor, filled with [EnumJsonifier] instance(s). Once provided, these enums can be
used as any base types.

#How to serialize other types
For a class C to be serializable, provide the `jsonifiers` parameter to the [Jsonifier]
constructor, filled with [ClassJsonifier]<C> or [StringEncodeJsonifier]<C> instance(s).
Once provided, the type C can be used as any base types.

[StringEncodeJsonifier] is intended for classes with simple data to serialize (eg. DateTime) witch can have a simple string representation. 
Extending [StringEncodeJsonifier] involves overriding its `toJson` and `fromJson` methods to provide a string representation of the state of C and rebuilding an instance of C from this encoded string value.

[ClassJsonifier] is intended for classes with complex structure. Ist `fromJson`/`toJson` methods receive/return a `Map<String,dynamic>` (typedef [JsonMap]) containing the class state. Extension [JsonMapExtension] provide methods on [JsonMap] to facilitate typed reads to properties in `fromJson` implementation. Encoding and decoding of [JsonMap] entries are automaticaly done by [Jsonifier].

