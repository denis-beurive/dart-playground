// This script illustrates the use of "Futures".
//
// A "Future" is returned by a function that executes asynchronously.
// When a "Future" is created, the asynchronous function that is responsible for
// initialising it may not be terminated yet. Therefore, when it's created, the
// "Future" is not complete. It will be complete (and so, ready to be used)
// at some point in the future (once the asynchronous function terminates its
// execution).
//
// See https://www.dartlang.org/tutorials/language/futures
//     https://api.dartlang.org/stable/2.0.0/dart-async/Future-class.html
//
// Please note that:
// - "async" creates a Future. However, this is not the only way to create Futures.
// - "async*" creates a Stream.

import 'package:colorize/colorize.dart';
import 'dart:async';
import 'dart:io';

// -----------------------------------------------------------------------------
// Creating Futures using "async".
//
// A function marked with the keyword "async" will run asynchronously. Thus it
// returns a Future.
// -----------------------------------------------------------------------------

/// Double a given value asynchronously.
/// [in_value] represents the value to double.
/// The function immediately returns an object, which is a Future.
/// This Future will not be complete after at least one second (may be more).
/// Please note the use of the keyword "async".
Future<int> sleep_and_double(int in_value) async {
  sleep(Duration(seconds: 1));
  return 2*in_value;
}

/// Triple a given value asynchronously, after a given period of time.
/// [in_value] represents the value to double.
/// [duration] represents the period of time to wait before the value is tripled.
/// The function immediately returns an object, which is a Future.
/// This Future will not be complete after the given period of time elapsed.
/// Please note the use of the keyword "async".
Future<int> sleep_and_triple(int in_value, [int duration=1]) async {
  sleep(Duration(seconds: duration));
  return 3*in_value;
}

int COUNTER = 0;

Future<bool> sleep_and_see() async {
  if (COUNTER > 10) {
    print(Colorize("COUNTER = ${COUNTER} => terminate")..lightCyan());
    return false;
  }
  print(Colorize("COUNTER = ${COUNTER} => continue")..lightCyan());
  COUNTER++;
  return true;
}

// -----------------------------------------------------------------------------
// Creating Futures using the Future API.
//
// The use of the keyword "async" is not the only way to create a Future.
// Futures can be created explicitly through the Future API.
// -----------------------------------------------------------------------------

/// Double a given value asynchronously.
/// [in_value] represents the value to double.
/// The function immediately returns an object, which is a Future.
/// This Future will not be complete after at least 3 seconds (may be more).
Future<int> another_sleep_and_double(int value) {
  return Future(() {
    sleep(Duration(seconds: 3));
    return 2*value;
  });
}


main() async {

  // ---------------------------------------------------------------------------
  // TEST: how to use Futures.
  // ---------------------------------------------------------------------------

  // The function "sleep_and_double()" returns immediately.
  // However, it takes 1 second to execute.
  // Obviously, the object "v" is not initialised when it is created.
  Future<int> v = sleep_and_double(10);

  // We assign a callback function to "v".
  // This callback function will be executed when "v" is complete - that is when
  // the execution of the function "sleep_and_double" terminates.
  v.then(
          (int value) => print(Colorize("[1] The asynchronous function sleep_and_double() finally terminate its treatment! The returned value is ${value}")..lightRed())
          // This callback function returns null.
          // However, it could return a Future.
  );

  // A shorter way to express the same code.
  sleep_and_double(10).then(
          (int value) => print(Colorize("[2] The asynchronous function sleep_and_double() finally terminate its treatment! The returned value is ${value}")..lightGreen())
  );

  // ---------------------------------------------------------------------------
  // TEST: chain of callback functions.
  // ---------------------------------------------------------------------------

  sleep_and_double(10).then((int value) {
    print(Colorize("[3] The asynchronous function sleep_and_double() finally terminate its treatment! The returned value is ${value}")..lightRed());
    return sleep_and_triple(value);
    // This callback function returns a Future.
  }).then((int value) {
    print(Colorize("[3] The asynchronous function sleep_and_double() finally terminate its treatment! The returned value is ${value}")..lightRed());
    // This callback function returns null.
  }).whenComplete(() {
    print(Colorize('[3] The execution is complete!')..lightRed());
  });

  // ---------------------------------------------------------------------------
  // TEST: wait for a Future to complete.
  // ---------------------------------------------------------------------------

  print(Colorize("[4] Wait 4 seconds...")..lightGreen());
  int value = await sleep_and_triple(10, 4);
  print(Colorize("[4] Done. Value is ${value}")..lightGreen());

  // ---------------------------------------------------------------------------
  // TEST: wait for multiple asynchronous calls to complete.
  // ---------------------------------------------------------------------------

  Future.wait([sleep_and_double(10), sleep_and_triple(10, 2)]).then((List<int> list) {
    print(Colorize('[5] The 2 asynchronous calls terminated! The returned values are:')..lightRed());
    list.forEach((int value) => print(Colorize("[5] > Value ${value}")..lightRed()));
    // This callback function returns null.
    // However, it could return a Future.
  });

  // ---------------------------------------------------------------------------
  // TEST: execute a list of asynchronous calls one after the other.
  //       Note that the same result could have been obtained by applying the
  //       technique used for the second test.
  // ---------------------------------------------------------------------------

  List<Future<int>> list = [sleep_and_double(10), sleep_and_triple(10, 5)];
  Future.forEach(list, (Future<int> future) {
    future.then((int value) {
      print(Colorize("[6] One asynchronous call terminated. Its returned value is ${value}")..lightGreen());
    });
  });

  // ---------------------------------------------------------------------------
  // TEST: execute an asynchronous call until it returns false.
  // ---------------------------------------------------------------------------

  Future.doWhile(sleep_and_see);

  // ---------------------------------------------------------------------------
  // TEST: wait for a Future to be fully created.
  // ---------------------------------------------------------------------------

  print(Colorize("[7] Wait 2 seconds")..lightRed());
  await Future.delayed(Duration(seconds: 2));
  print(Colorize("[7] Done!")..lightRed());

  // ---------------------------------------------------------------------------
  // TEST: call a function that returns a Future explicitly created.
  // ---------------------------------------------------------------------------

  print(Colorize("[8] Call another_sleep_and_double(31) now")..lightGreen());
  Future<int> d = another_sleep_and_double(31);
  d.then(
          (int value) => print(Colorize("[8] The Future returned by the function another_sleep_and_double() is complete. The value is ${value}")..lightGreen())
  ).then((var notUsed) => print(Colorize('[8] Done')..lightGreen()));

  // ---------------------------------------------------------------------------
  // TEST: explain FutureOr<T>.
  // Future<T>.delayed(Duration duration, [ FutureOr<T> computation() ])
  // ---------------------------------------------------------------------------

  Future<int> f1 = Future.delayed(Duration(seconds: 1), () => 10);
  f1.then((int value) => print(Colorize("[9] -> ${value}")..lightRed()));

  Future<int> f2 = Future.delayed(Duration(seconds: 1), () => Future<int>(() => 10));
  f2.then((int value) => print(Colorize("[10] -> ${value}")..lightGreen()));

  Future<int> f3 = Future.delayed(Duration(seconds: 1), () => Future<int>(() => Future<int>(() => 10)));
  f3.then((int value) => print(Colorize("[10] -> ${value}")..lightRed()));



}
