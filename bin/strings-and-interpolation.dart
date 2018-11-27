import 'dart:math';

main() {

  // The notation can evaluate an expression.

  print("The boolean value is ${Random.secure().nextBool() ? 'true' : 'false'}");

  // If you need to interpolate code that cannot be expressed as an expression,
  // then it must be encapsulated into an anonymous function.

  print("The boolean value is ${(() { if (Random.secure().nextBool()) { return 'true'; } else { return 'false'; }})() }");

  print("""
This is a multiline string that interpolates the result of an anonymous function.
${(
          (int value) => "Random value: ${value}"
)(Random.secure().nextInt(100))}
""");

}