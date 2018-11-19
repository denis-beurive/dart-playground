// This file illustrates the different patterns found in function signatures.
//
// Dart allows the following constructs:
//      - Mandatory positional parameters.
//      - Optional positional parameters.
//      - Mandatory positional parameters, followed by optional positional parameters.
//      - Optional named parameters.
//
// Notes:
//      - All optional parameters, whether it positional or named, have an implicit
//        default value: null.
//      - There is no splat operator with Dart.
//        https://www.reddit.com/r/dartlang/comments/psjy4/does_dart_have_splats_like_python_or_ruby/
//      - There are no functions with a variable number of arguments with Dart:
//        https://stackoverflow.com/questions/13731631/creating-function-with-variable-number-of-arguments-or-parameters-in-dart

// -----------------------------------------------------------------------------
// Mandatory positional parameters.
// -----------------------------------------------------------------------------

/// Generate the string that represents the identity of the user, given his first
/// and last names. All parameters are mandatory.
/// [firstName] represents the user's first name.
/// [lastName] represents the user's last name.
String mandatoryNamedIdentity(String firstName, String lastName) {
  return "His name is ${firstName} ${lastName}.";
}

// -----------------------------------------------------------------------------
// Optional positional parameters.
// -----------------------------------------------------------------------------

/// Generate the string that represents the identity of the user, given his first
/// and last names. All parameters are mandatory.
/// [firstName] represents the user's first name.
/// [lastName] represents the user's last name. This parameter is optional. Its
///            default value is 'Daniels'.
/// [age] represents the user's age. The default implicit value is null.
String mandatoryAndOptionalNamedIdentity(String firstName, [String lastName='Daniels', int age]) {
  return "His name is ${firstName} ${lastName} and his age is ${age}.";
}

// -----------------------------------------------------------------------------
// Optional named parameters without explicitly assigned default values.
// -----------------------------------------------------------------------------

/// Generate the string that represents the identity of the user, given his first
/// and last names.
/// [firstName] represents the user's first name. The implicit default value is null.
/// [lastName] represents the user's last name. The implicit default value is null.
String formatIdentity({String firstName, String lastName}) {
  return "His name is ${firstName} ${lastName}.";
}

// -----------------------------------------------------------------------------
// Optional named parameters with explicitly assigned default values.
// -----------------------------------------------------------------------------

/// Generate the string that represents the identity of the user, given his first
/// and last names.
/// [firstName] represents the user's first name. The implicit default value is 'Jack'.
/// [lastName] represents the user's last name. The implicit default value is null.
String formatDefaultIdentity({String firstName='Jack', String lastName}) {
  return "His name is ${firstName} ${lastName}.";
}


main() {

  print(mandatoryNamedIdentity('Jack', 'Daniels')); // => His name is Jack Daniels.

  print(mandatoryAndOptionalNamedIdentity('Jack')); // => His name is Jack Daniels and his age is null.

  print(mandatoryAndOptionalNamedIdentity('Jack', "Daniels", 30)); // => His name is Jack Daniels and his age is 30.

  print(formatIdentity(
    lastName: 'Daniels',
    firstName: 'Jack'
  )); // => His name is Jack Daniels.

  print(formatIdentity(
      lastName: 'Daniels'
  )); // => His name is null Daniels.

  print(formatDefaultIdentity(
    lastName: 'Daniels'
  )); // => His name is null Daniels.
}


