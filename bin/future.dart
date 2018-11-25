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
// - "async" creates a Future.
// - "async*" creates a Stream.

import 'dart:async';
import 'dart:io';

Future<int> sleep_and_double(int in_value) async {
  sleep(Duration(seconds: 1));
  return 2*in_value;
}

Future<int> sleep_and_triple(int in_value, [int duration=1]) async {
  sleep(Duration(seconds: duration));
  return 3*in_value;
}

int COUNTER = 0;

Future<bool> sleep_and_see() async {
  if (COUNTER > 10) {
    print("COUNTER = ${COUNTER} => terminate");
    return false;
  }
  print("COUNTER = ${COUNTER} => continue");
  COUNTER++;
  return true;
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
          (int value) => print("The asynchronous function sleep_and_double() finally returned! The returned value is ${value}")
          // This callback function returns null.
          // However, it could return a Future.
  );

  // A shorter way to express the same code.
  sleep_and_double(10).then(
          (int value) => print("The asynchronous function sleep_and_double() finally returned! The returned value is ${value}")
  );

  // ---------------------------------------------------------------------------
  // TEST: chain of callback functions.
  // ---------------------------------------------------------------------------

  sleep_and_double(10).then((int value) {
    print("The asynchronous function sleep_and_double() finally returned! The returned value is ${value}");
    return sleep_and_triple(value);
    // This callback function returns a Future.
  }).then((int value) {
    print("The asynchronous function sleep_and_triple() finally returned! The returned value is ${value}");
    // This callback function returns null.
  }).whenComplete(() {
    print('The execution is complete!');
  });

  // ---------------------------------------------------------------------------
  // TEST: wait for a Future to complete.
  // ---------------------------------------------------------------------------

  print("Wait 4 seconds...");
  int value = await sleep_and_triple(10, 4);
  print("Done. Value is ${value}");

  // ---------------------------------------------------------------------------
  // TEST: wait for multiple asynchronous calls to complete.
  // ---------------------------------------------------------------------------

  Future.wait([sleep_and_double(10), sleep_and_triple(10, 2)]).then((List<int> list) {
    print('The 2 asynchronous calls terminated! The returned values are:');
    list.forEach((int value) => print("> Value ${value}"));
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
      print("One asynchronous call terminated. Its returned value is ${value}");
    });
  });

  // ---------------------------------------------------------------------------
  // TEST: execute an asynchronous call until it returns false.
  // ---------------------------------------------------------------------------

  Future.doWhile(sleep_and_see);

  // ---------------------------------------------------------------------------
  // TEST: wait for a Future to be fully created.
  // ---------------------------------------------------------------------------

  print("Wait 2 seconds");
  await Future.delayed(Duration(seconds: 2));
  print("Done!");
}
