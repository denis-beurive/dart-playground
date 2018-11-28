// This script illustrates the concept of immutability in Dart.
//
// Wikipedia:
//
//    In object-oriented and functional programming, an immutable object (unchangeable object)
//    is an object whose state cannot be modified after it is created. This is in contrast
//    to a mutable object (changeable object), which can be modified after it is created.
//
// const: define immutable bonds to immutable objects that are initialised at compile time.
// final: define immutable bonds to (unless otherwise stated) mutable objects that are initialised at runtime.
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
  const Metadata.forever(String this._onError);
  String toString() => _onError;
}



main() {

  // ---------------------------------------------------------------------------
  // Synopsis
  // ---------------------------------------------------------------------------

  Map<int, int> a = {};             // "a" is bound to the (anonymous) object {}.
  Map<int, int> b = a;              // "b" is bound to the (names) object "a".
  final Map<int, int> c = a;        // the bond between "c" and "a" is immutable. However, you can change the "content" of "a".
  c[10] = 100;                      // this is OK. The bound object is mutable.
  a[10] = 100;                      // this is OK. The bound object is mutable.
  const Map<int, int> d = {};       // the bond between "d" and the (anonymous) object {} is immutable. And the bound object is immutable.
  Map<int, int> e = const {};       // the bond between "e" and the (anonymous) object {} is mutable. However, the bound object is immutable.
  e = {1: 10};                      // this is OK.

  // "f" is created at runtime. The bond is immutable and the bound object is immutable.
  // This is "looks like" a "const" variable... but initialised at runtime.
  final Metadata f = Metadata.forever('exitOnError-' + Random.secure().nextInt(100).toString());

  // ---------------------------------------------------------------------------
  // const: define immutable bonds to immutable objects that are initialised at
  //        compile time.
  // ---------------------------------------------------------------------------

  const Map mm1 = const {};
  const Map mm2 = {};
  print("mm1 == mm2 ? " + (mm1 == mm2).toString()); // => mm1 == mm2 ? true
  // mm1 = mm2; Although mm1 and mm2 reference the same object, this code is forbidden.

  // You could also write: const Map<String, int> m1 = const { 'a': 1, 'b': 2 };
  const Map<String, int> m1 = { 'a': 1, 'b': 2 };

  try { m1['d'] = 3; } catch (e) { print("[1] You cannot do that! ${e}"); }
  // => [1] You cannot do that! Unsupported operation: Cannot set value in unmodifiable Map
  // m1 = {}; Is forbidden, at compile time, this time.

  try {
    ((Map<String, int> m) { m['a'] = 1; })(const {});
  } catch (e) {
    print("[2] You cannot do that! ${e}");
  }
  // => [2] You cannot do that! Unsupported operation: Cannot set value in unmodifiable Map

  ((Map<String, int> m) {
    print("This immutable anonymous parameter is: " + m.toString());
  })(const { 'a': 1, 'b': 2});
  // => This immutable anonymous parameter is: {a: 1, b: 2}

  // ---------------------------------------------------------------------------
  // const constructors.
  // ---------------------------------------------------------------------------

  const Metadata meta1 = Metadata.forever('logoutAndClose');
  Metadata meta2 = Metadata('logoutAndMove');
  print("meta1: ${meta1}");
  print("meta2: ${meta2}");
  meta2 = Metadata('logoutAndRevert');
  print("meta2: ${meta2}");

  // The bond between "meta3" is not mutable.
  // However, the bound (anonymous) object is immutable.
  Metadata meta3 =  Metadata.forever('logoutAndClose');
  print("meta3: ${meta3}");
  meta3 = Metadata('logoutAndMove');
  print("meta3: ${meta3}");

  // ---------------------------------------------------------------------------
  // final: define immutable bonds to (unless otherwise stated) mutable objects
  //        that are initialised at runtime.
  // ---------------------------------------------------------------------------

  final int randomValue = Random.secure().nextInt(100);
  print("The value of the runtime immutable variable <randomValue> is ${randomValue}. It will change from execution to execution.");

  final Map<String, int> map1 = { 'a': 1 };
  // map = {}; This code is not valid. The bond is not mutable.
  map1['a'] = 2; // OK => The bound object is mutable.
  map1['b'] = 3; // OK => The bound object is mutable.
  print("map = ${map1}"); // => map = {a: 2, b: 3}

  final Map<String, int> map2 = const { 'a': 1 };
  try {
    map2['a'] = 2; // KO => The bound object is not mutable.
  } catch (e) { print("[3] You cannot do that! ${e}"); }
  // [3] You cannot do that! Unsupported operation: Cannot set value in unmodifiable Map

  Log log1 = Log('/path/to/log');
  Log log2 = Log('/path/to/log');
  final Log log3 = Log('/path/to/log');
  print("log1 == log2 ? " + (log1 == log2).toString()); // => false
  log1 = log3; // This is OK. However, you cannot write: log3 = log1 (the bond is not mutable)




}