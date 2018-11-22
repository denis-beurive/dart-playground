// This script illustrates the use of the keyword "await".
// The use of the keyword "await" makes the call to an asynchronous function
// behave like a synchronous one. The execution of the next instruction does not
// start until the asynchronous call terminates.
//
// You can wait for a Future to complete.
// You can wait for data to be available in a Stream.
// You can wait for data to be available in a ReceivePort (which is a Stream).

import 'dart:async';
import 'dart:io';

typedef Streamer = Stream<int> Function();

class Container {
  static int _counter = 1;

  static Future<void> sleep_and_print([int duration=2]) async {
    sleep(Duration(seconds: duration));
    print("Publishing data ${_counter++}");
  }

  static Future<String> sleep_and_return([int duration=2]) async {
    sleep(Duration(seconds: duration));
    return "Publishing data ${_counter++}";
  }
}

main() async {

  // ---------------------------------------------------------------------------
  // Wait for a Future to complete.
  // ---------------------------------------------------------------------------

  // Although the function executes asynchronously, the next execution does not
  // start before the current one terminates.

  await Container.sleep_and_print(1);
  print("...");
  await Container.sleep_and_print(1);
  print("...");
  await Container.sleep_and_print(1);
  print("...");

  // This is functionally equivalent to the code below.
  // Please note that if we don’t specify the keyword "await", then the next
  // instruction (the call to sleep_and_return()) would be executed immediately.

  await Container.sleep_and_print(1)
      .then((void value) => Container.sleep_and_print(1))
      .then((void value) => Container.sleep_and_print(1));

  // We may also use a returned value.

  String v = await Container.sleep_and_return(1);
  print("The data collected is ${v}");
  v = await Container.sleep_and_return(1);
  print("The data collected is ${v}");
  v = await Container.sleep_and_return(1);
  print("The data collected is ${v}");

  // ---------------------------------------------------------------------------
  // Wait for a data to be available in a stream.
  // ---------------------------------------------------------------------------

  Streamer streamCreator = () async* {
    for(int i=0; i<3; i++) {
      yield 3*i;
      sleep(Duration(seconds: 1));
    }
  };

  await for (int value in streamCreator()) {
    print("> ${value}");
  }

  print("Terminate the script");
}