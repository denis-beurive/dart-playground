
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
}
