// This script illustrates the concept of immutability in Dart.
//
// Wikipedia:
//
//    In object-oriented and functional programming, an immutable object (unchangeable object)
//    is an object whose state cannot be modified after it is created. This is in contrast
//    to a mutable object (changeable object), which can be modified after it is created.
//
// const: define immutable bonds to immutable objects that are initialised at compile-time.
//        >> const <type> <varName> = [const] <object>
//        OR
//        define immutable objects that are initialised at compile-time.
//        >> const <object>
// final: define immutable bonds to (unless otherwise stated) mutable objects that
//        are (unless otherwise stated) initialised at runtime.
//        >> final <type> <varName> = [const] <object>
//
// "const constructors": these constructors can be used to
//    [1] instantiate a compile-time immutable object.
//        >> const <type> <varName> = [const] <constructor>(...)
//        >> const <constructor>(...)
//    [2] instantiate a runtime immutable object.
//        >> <type> <varName> = <constructor>(...)
//        >> <constructor>(...)
//
// In any cases, a "const constructors" instantiates an immutable object.
// However, the instantiation may be performed at compile-time or at runtime,
// depending on the context - which is determined by the presence or the absence
// of the keyword "const":
//
//   - If the keyword "const" is used, then the instantiation is performed at
//     compile-time.
//   - Otherwise, the instantiation is performed ar runtime.
//
// See: https://pub.dartlang.org/documentation/matcher/latest/matcher/matcher-library.html
// See: https://stackoverflow.com/questions/21744677/how-does-the-const-constructor-actually-work
// See: https://medium.com/dartlang/an-intro-to-immutability-with-dart-d4de871865c7

import 'dart:math';

/// This class represents a LOG file.
class Log{
  final String _path; // This property is not initialised until the class is instantiated.
  final Map<String, bool> _mode = { 'read': false, 'write': true };

  Log(this._path);
  void setRead([bool mode=true]) { _mode['read'] = mode; }
  void setWrite([bool mode=true]) { _mode['write'] = mode; }
  Map<String, bool> getMode() => _mode;
  String getPath() => _path;
}

/// This class represents a metadata.
/// Please note that
class Metadata {
  static const TAG = 'matadata'; // const properties must be static (class properties).
  final String _onError;
  Metadata(String this._onError);

  /// "const" constructor.
  /// This constructor returns an object that can be used:
  ///
  /// [1] within a "const" construction:
  ///     - const <type> <varName> = [const] Metadata.forever(...)
  ///     - const Metadata.forever(...)
  ///
  /// [2] within a "non-const" construction:
  ///     - <type> <varName> = Metadata.forever(...)
  ///     - Metadata.forever(...)
  ///
  /// When used in a "const context", the constructor parameter must be a constant
  /// expression. However, in a "non-const" context, the constructor parameter does
  /// not have to be a constant expression.
  const Metadata.forever(String this._onError);
  String toString() => _onError;
}

/// This function is used to let the compiler think that a variable is used while it is not.
/// This is just a trick to avoid warnings from the compiler/editor.
/// [v] represents any variable.
void noop(var v) {}

main() {

  // ---------------------------------------------------------------------------
  // Overview
  // ---------------------------------------------------------------------------

  // Bond between a variable name and a (named or anonymous) object.

  Map<int, int> a = {};             // "a" is bound to the (anonymous) object {}.
  Map<int, int> b = a;              // "b" is bound to the (names) object "a".
  noop(b);

  // final.

  final Map<int, int> c = a;        // the bond between "c" and "a" is immutable. However, you can change the "content" of "a".
  c[10] = 100;                      // this is OK. The bound object is mutable.
  a[10] = 100;                      // this is OK. The bound object is mutable.

  // const.

  const Map<int, int> d = {};       // the bond between "d" and the (anonymous) object {} is immutable. And the bound object is immutable.
  Map<int, int> e = const {};       // the bond between "e" and the (anonymous) object {} is mutable. However, the bound object is immutable.
  e = {1: 10};                      // this is OK.
  noop([d, e]);

  // The bond between "mapToConstObject" and the (anonymous) object {} is mutable.
  // The bound object ({}) is immutable.
  Map<String, int> mapToConstObject = const {};
  try { mapToConstObject['a'] = 1; } catch (e) { print("You cannot do that! ${e}"); }
  // => You cannot do that! Unsupported operation: Cannot set value in unmodifiable Map
  mapToConstObject = { 'a':10, 'b':20 }; // OK

  // final + const: making variables that look like "const" variables... but initialised at runtime.

  // The bond between "finalMapToConstObject" and the (anonymous) object {} is immutable.
  // The bound object is immutable.
  final finalMapToConstObject = const {};
  try { finalMapToConstObject['a'] = 1; } catch (e) { print("You cannot do that! ${e}"); }
  // => You cannot do that! Unsupported operation: Cannot set value in unmodifiable Map
  // This expression below is not allowed. It raises a compile-time error.
  // Final variable can only be set once.
  // finalMap = {};

  // "finalMetadataToConstInstance" is created at runtime. The is immutable.
  // The bound object is immutable (it has been instantiated using a "const" constructor).
  final Metadata finalMetadataToConstInstance = Metadata.forever('exitOnError-' + Random.secure().nextInt(100).toString());
  noop(finalMetadataToConstInstance);

  // ---------------------------------------------------------------------------
  // const: 1. const <type> <varName> = <anonymous object>
  //           Creates an immutable bond to an immutable (anonymous) object that
  //           is initialised at compile-time.
  //        2. const <anonymous object>
  //           Creates an immutable (anonymous) object that is initialised at
  //           compile-time.
  // ---------------------------------------------------------------------------

  // This test shows the immutability of the bond and the bound object.
  (() {
    const Map<String, int> v1 = { 'a': 1, 'b': 2 };
    try { v1['d'] = 3; } catch (e) { print("You cannot do that! ${e}"); }
    // => You cannot do that! Unsupported operation: Cannot set value in unmodifiable Map
    try {
      ((Map<String, int> m) { m['a'] = 1; })(const {});
    } catch (e) { print("You cannot do that! ${e}"); }
    // => You cannot do that! Unsupported operation: Cannot set value in unmodifiable Map
    // v1 = {}; Is forbidden, at compile-time, this time.
  })();

  // This test illustrates the fact that all "const" variables that reference "identical"
  // values reference a unique object. In other words, they hold the same value.
  (() {
    // v1, v2 and v3 reference a unique object.
    const Map v1 = const {};
    const Map v2 = {};
    Map v3 = const {};
    print("v1 == v2 ? " + (v1 == v2).toString()); // => v1 == v2 ? true
    print("v1 == v3 ? " + (v1 == v3).toString()); // => v1 == v3 ? true
    print("const {} == v1 ? " + (const {} == v1).toString()); // => const {} == v1 ? true
    // v1 = v2; Although v1 and v2 reference the same object, this code is forbidden.
  })();

  // ---------------------------------------------------------------------------
  // const constructors.
  // ---------------------------------------------------------------------------

  (() {
    // "meta1" is created by calling the "const" constructor, while "meta2" don't.
    const Metadata meta1 = Metadata.forever('logoutAndClose');
    Metadata meta2 = Metadata('logoutAndClose');
    Metadata meta3 = Metadata.forever('logoutAndClose');
    Metadata meta4 = const Metadata.forever('logoutAndClose');
    const Metadata meta5 = Metadata.forever('logoutAndClose');
    print("meta1 == meta2 ? " + (meta1 == meta2).toString()); // => meta1 == meta2 ? false
    print("meta1 == meta3 ? " + (meta1 == meta3).toString()); // => meta1 == meta3 ? false
    print("meta1 == meta4 ? " + (meta1 == meta4).toString()); // => meta1 == meta4 ? true
    print("meta1 == meta5 ? " + (meta1 == meta5).toString()); // => meta1 == meta5 ? true
    print("Metadata.forever('logoutAndClose') == meta1 ? " + (Metadata.forever('logoutAndClose') == meta1).toString()); // => Metadata.forever('logoutAndClose') == meta1 ? false
    print("const Metadata.forever('logoutAndClose') == meta1 ? " + (const Metadata.forever('logoutAndClose') == meta1).toString()); // => const Metadata.forever('logoutAndClose') == meta1 ? true

    // Try to use a non-constant parameter as argument for the "const" constructor.
    // Please note that the 2 lines below are not valid:
    //     const Metadata meta7 = Metadata.forever('logoutAndClose' + Random.secure().nextInt(100).toString());
    //     Metadata meta7 = const Metadata.forever('logoutAndClose' + Random.secure().nextInt(100).toString());
    // However, the line that immediately follows this comment is valid.
    Metadata meta6 = Metadata.forever('logoutAndClose' + Random.secure().nextInt(100).toString()); // OK
    ((Metadata m) { print(m); })(Metadata.forever('logoutAndClose' + Random.secure().nextInt(100).toString()));

    noop(meta6);
  })();

  // ---------------------------------------------------------------------------
  // final: define immutable bonds to (unless otherwise stated) mutable objects
  //        that are initialised at runtime.
  // ---------------------------------------------------------------------------

  // This test illustrates the fact that a "final" object is created at runtime.
  ((){
    final int randomValue = Random.secure().nextInt(100);
    print("The value of the runtime immutable variable <randomValue> is ${randomValue}. It will change from execution to execution.");
  })();

  // This test illustrates the fact that "final" defines an immutable bond to a
  // (unless otherwise stated) mutable objects
  ((){
    final Map<String, int> map = { 'a': 1 };
    // map = {}; This code is not valid. The bond is not mutable.
    map['a'] = 2; // OK => The bound object is mutable.
    map['b'] = 3; // OK => The bound object is mutable.
    print("map = ${map}"); // => map = {a: 2, b: 3}

    Log log1 = Log('/path/to/log');
    Log log2 = Log('/path/to/log');
    final Log log3 = Log('/path/to/log');
    log1 = log3; // This is OK. However, you cannot write: log3 = log1 (the bond is not mutable)
    log1 = log2; // This is OK.
    noop(log1);

    const Metadata log4 = Metadata.forever('toto');
    final Metadata log5 = const Metadata.forever('toto');
    final Metadata log6 = Metadata.forever('toto');
    print("log4 == log5 ? " + (log4 == log5).toString()); // => log4 == log5 ? true
    print("log4 == log6 ? " + (log4 == log6).toString()); // => log4 == log6 ? false
  })();

  // ---------------------------------------------------------------------------
  // final and const
  // ---------------------------------------------------------------------------

  // "const" can be used in conjunction to "final".
  (() {
    final Map<String, int> map = const { 'a': 1 };
    try {
      map['a'] = 2; // KO => The bound object is not mutable.
    } catch (e) { print("You cannot do that! ${e}"); }
    // You cannot do that! Unsupported operation: Cannot set value in unmodifiable Map
  })();
}