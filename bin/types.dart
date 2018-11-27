import 'dart:async';
import 'dart:io';

// -----------------------------------------------------------------------------
// TEST: class that emulate functions.
// -----------------------------------------------------------------------------

/// This class emulates a function that takes two integers and returns an integer.
class MyClassFunction {
  int call(int a, int b) {
    return a+b;
  }
}

/// This abstract class is used to declare a function that performs a type
/// conversion (from type S to type T).
abstract class CasterFunction<S, T> {
  T call(S value);
}

// This class emulates a function that converts an integer into a string.
class MyCasterFunction extends CasterFunction<int, String> {
  String call(int value) {
    return "<${value.toString()}>";
  }
}

main() {
  MyClassFunction f1 = MyClassFunction();
  print(f1(10,20));
  CasterFunction f2 = MyCasterFunction();
  print(f2(10));

  // ---------------------------------------------------------------------------
  // TEST: dynamics
  // ---------------------------------------------------------------------------

  dynamic a = [1, 'a']; // a is a list.
  print("Is a the variable \"a\" a list<dynamic> ? ${a is List<dynamic> ? 'yes' : 'no'}");

  // Or...

  List<dynamic> b = [1, 'a'];
  print("Is a the variable \"b\" a list<dynamic> ? ${b is List<dynamic> ? 'yes' : 'no'}");

  // Or...

  var c = [1, 'a']; // a is a list.
  print("Is a the variable \"c\" a list<dynamic> ? ${c is List<dynamic> ? 'yes' : 'no'}");

  // Please note that the answers to the questions below are:
  // - yes
  // - yes

  var d = [1, 2]; // a is a list.
  print("Is a the variable \"d\" a list<dynamic> ? ${d is List<dynamic> ? 'yes' : 'no'}"); // => yes
  print("Is a the variable \"d\" a list<int> ? ${d is List<int> ? 'yes' : 'no'}"); // => yes

  // ---------------------------------------------------------------------------
  // TEST: what is FutureOr ?
  // ---------------------------------------------------------------------------

  // How to interpret this signature ?
  //
  //     Future<T>.delayed(Duration duration, [ FutureOr<T> computation() ])
  //
  // This is a constructor which takes one mandatory argument (duration), and
  // one optional argument (the function computation()).
  // - The first (mandatory argument) is the time to wait.
  // - The second argument is a function that may return:
  //   * A value (of type <int>) that will be passed to the Future "then" handler.
  //   * "OR" a Future<int>.
  //
  // FutureOr<T> is just a notation that means: Future<T> or <T>
  
  // 1> The second argument is a value (of type <int>) that will be passed to the
  //    Future handler.

  Future<int> fint1 = Future<int>.delayed(Duration(seconds: 1), () => 10 ); // Return an integer.
  fint1.then((int value) { print("[1] 1 second ellapsed! Git ${value}"); });

  // Which can be anonymously expressed:

  Future<int>.delayed(Duration(seconds: 1), () => 10 )
      .then((int value) { print("[2] 1 second ellapsed! Git ${value}"); });

  // 2> The second argument is as Future<int>.

  var computation = () {
    print("Start the computation...");
    // Do a lot of things...
    sleep(Duration(seconds: 2));
    print("The computation is node! Start another treatment!");
    return Future<int>(() => 100);
  };

  Future<int> fint2 = Future<int>.delayed(
      Duration(seconds: 1),
      () => Future<int>(computation) // Return a Future<int>
  );

  fint2.then((int value) { print("[3] The computation is done!"); });

  // ---------------------------------------------------------------------------
  // TEST: primitive and non-primitive types.
  // ---------------------------------------------------------------------------

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

  // Primitive types are manipulated by value.

  String s1 = 'Fr'
      'ist string';
  String s2 = s1;
  s2 = s2.toUpperCase();
  assert(s1 != s2 && 'Frist string' == s1); // This assertion is true.

  // Non-primitive types are manipulated by reference.

  Map<String, int> m1 = {
    'a': 1,
    'b': 2
  };
  Map<String, int> m2 = m1;
  m2['c'] = 3;
  assert(m1.containsKey('c') && 3 == m1['c']); // This assertion is true.

  ((Map<String, int> m) {
    m['d'] = 4;
  })(m1);
  assert(m1.containsKey('d') && 4 == m1['d']); // This assertion is true.




}
