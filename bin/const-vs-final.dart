
// In object-oriented and functional programming, an immutable object (unchangeable object)
// is an object whose state cannot be modified after it is created. This is in contrast
// to a mutable object (changeable object), which can be modified after it is created.
//
// The keyword "const" is used to create an "immutable bound" *AND* an "immutable object".
// This is symbolized by this: "const Map m = {}" is identical to "const Map m = const {}".
//
// - Immutable objects are initialized at compile time.
// - Two immutable objects that reference "content identical" objects reference the same object.
//   In other words:
//   "const Map m1 = {}; const Map m2 = {};" => "m1 == m2" will return the value true.
//   However, this is not true for mutable objects:
//   "Map m1 = {}; Map m2 = {};" => "m1 == m2" will return the value false.
// - Immutable objects cannot be assigned to object properties. They can only be
//   assigned to class properties (that is to "static" properties).
//
// The keyword "final" is used to create objects that can be initialized only once, at runtime.
//
// See: https://pub.dartlang.org/documentation/matcher/latest/matcher/matcher-library.html
// See: https://stackoverflow.com/questions/21744677/how-does-the-const-constructor-actually-work
// See: https://medium.com/dartlang/an-intro-to-immutability-with-dart-d4de871865c7

import 'dart:math';
import "package:test/test.dart";

// The keyword "const" is used to specify that the variable is a compile time constant.
// The value of this variable cannot be modified at runtime.
const String compileTimeConstantCityStringVariable = 'France';

// The value of a final variable is not known at compile time.
// Its value can be initialised at runtime only once.
final bool debug = Random.secure().nextBool();

class Address {
  // The keyword "const" can be used within a class. However it can be applied
  // to static properties (also called class properties) only. This restriction
  // makes sense since there would be no reason to define an instance property
  // which value cannot change from an instance to the other.
  // Ever hear of Occam's razor? "Pluralitas non est ponenda sine necessitate"

  static const String defaultCountry = 'France';
  static const Map<String, int> countryCodes = {
    'Belgium': 32,
    'France': 33,
    'Spain': 34
  };
  static const Map<String, String> capitalCities = const {
    'Belgium': 'Bruxelles',
    'France': 'Paris',
    'Spain': 'Madrid'
  };

  static const String defaultCapitalCity = capitalCities[defaultCountry];

  // The keyword "final" can be used within a class.
  // Contrary to a "const" property:
  // - a "final" property can apply to instance variables.
  // - and a "final" property is initialised at runtime.

  final String name = "The country is ${defaultCountry}";
  final bool _debug = Random.secure().nextBool();

  bool isDebugOn() => _debug;
}

// "immutable" constructors are used to instantiate objects that will be assigned
// to "immutable" variables.
class Log{
  final String _path;
  // Cannot be called if the instantiated object is assigned to a "non-const" variable.
  Log(this._path);
  // Must be called if the instantiated object is assigned to a "const" variable.
  const Log.forEver(this._path);
  String getPath() => _path;
}




main() {

  const Map mm1 = const {};
  const Map mm2 = {};
  print(mm1 == mm2);


  // ---------------------------------------------------------------------------
  // const
  // ---------------------------------------------------------------------------

  // Reminder
  // ========
  //
  // In Dart, every variable is an object. The class which defines the instantiated
  // object is called the "type" of the variable.
  //
  // However, some classes have constructors, others don't.
  // For example:
  // - The class "String" does not have a constructor.
  // - The class "Map" has a constructor.
  //
  // Classes that don't have a constructor represents primitive types (ex: String, int...).
  // Classes that have a constructor represents non-primitive types (ex: String, int...).
  //
  // See: https://github.com/denis-beurive/dart-playground/blob/master/bin/types.dart


  // In Dart, the keyword "const" defines both an "immutable binding" *AND* an
  // "immutable object".
  //
  // Illustration:
  //
  // Map is a non-primitive type. Thus, It is manipulated by reference.
  //
  // "m1" carries a reference to an (anonymous) object.
  //
  // The presence of the keyword "const" in front of the declaration implies that:
  //
  // [1] the value of "m1" (the reference) is constant. Thus "m1" will always
  //     reference the same (anonymous) object. This property is called
  //     "immutable binding"
  // [2] the content of the referenced (anonymous) object is immutable.

  const Map<String, int> m1 = {
    'a': 1,
    'b': 2
  };

  // You could also write:
  //
  // const Map<String, int> m1 = const {
  //    'a': 1,
  //    'b': 2
  // };

  test("You cannot modify the content of the object referenced by m1.",
      // m1['d'] = 3; // Is forbidden.
      () { expect(() { try { m1['d'] = 3; } catch (e) { throw Exception(); } },  throwsException); }
  );

  // m1 = {}; Is forbidden, at compile time, this time.

  test("You cannot modify the content of the immutavle object referenced by m.",
    () { expect(() { try {
      ((Map<String, int> m) { m['a'] = 1; })(const {});
    } catch (e) {
      throw Exception();
    }}, throwsException); }
  );

  // ---------------------------------------------------------------------------
  // "immutable" constructors.
  // ---------------------------------------------------------------------------

  // Comparing mutable variables.
  // Although the "contents" of the objects referenced by "log1" and "log2" are
  // identical, "log1" and "log2" reference different objects.
  Log log1 = Log('/path/to/log');
  Log log2 = Log('/path/to/log');
  // log1 and log2 reference *DIFFERENT* objects.
  print(log1 == log2); // => false

  print(Log.forEver('/path/to/log') == Log.forEver('/path/to/log')); // => false

  // Comparing "immutable" variables.
  // This line below is forbidden:
  // const Log logForEver1 = Log('/path/to/log');

  // As you can see, "logForEver1" and "logForEver2" reference the same object.
  const Log logForEver1 = Log.forEver('/path/to/log');
  const Log logForEver2 = Log.forEver('/path/to/log');
  const Log logForEver3 = Log.forEver('/path/to/newlog');
  // logForEver1 and logForEver2 reference the *SAME* object.
  print(logForEver1 == logForEver2); // => true
  // logForEver1 and logForEver3 reference *DIFFERENT* objects.
  print(logForEver1 == logForEver3); // => false

  // ---------------------------------------------------------------------------
  // final
  // ---------------------------------------------------------------------------

  print(Address.defaultCapitalCity);
  // The two function call below may produce different outputs.
  print("Debug ? " + (Address().isDebugOn() ? 'true' : 'false'));
  print("Debug ? " + (Address().isDebugOn() ? 'true' : 'false'));
}