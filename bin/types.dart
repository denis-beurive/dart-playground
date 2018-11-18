
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
}
