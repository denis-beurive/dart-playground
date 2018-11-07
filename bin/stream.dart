// https://www.dartlang.org/tutorials/language/streams
// https://www.dartlang.org/articles/libraries/creating-streams

import 'dart:async';
import 'dart:io';
import 'dart:math';

class Container {
  static Random _random_generator = Random(123);

  // This function creates a stream of integers.
  static Stream<int> streamer() async* {
    for (int i=0; i<3; i++) {
      int v = _random_generator.nextInt(1000);
      print("Wait 2 seconds and then generate a value ${v}");
      sleep(Duration(seconds: 2));
      yield v;
    }
  }
}

main() async {

  // ---------------------------------------------------------------------------
  // TEST 1: create a single subscription stream.
  // ---------------------------------------------------------------------------

  // https://api.dartlang.org/stable/2.0.0/dart-async/Stream-class.html:
  //   Such a stream can only be listened to once. A single-subscription stream
  //   allows only a single listener during the whole lifetime of the stream. It
  //   doesn't start generating events until it has a listener, and it stops
  //   sending events when the listener is unsubscribed, even if the source of
  //   events could still provide more.

  // Create a stream.
  print("Start the stream creator now");
  Stream<int> s = Container.streamer();
  print("The stream is created, however it did not emit any value yet (since no listener is litening to it)");

  print("Wait 5 seconds, just to show that the stream will start to emit only when a listener will listen to it.");
  sleep(Duration(seconds: 5));
  print("OK. Now let start to listen to the stream. This will start the emission of values.");

  // The method "ForEach()" returns a "Future". Thus it executes asynchronously.
  // Unless you indicate the keyword "await", the execution of the next instruction
  // starts immediately.
  // Note: now the stream is assigned a listener! So it starts emitting values.
  await s.forEach((int value) => print("- The value ${value} has been emited."));
  print('Done');

  // Or, we could have written...

  print('Start waiting for values from the stream...');
  await for (int value in Container.streamer()) {
    print("Received one value from the stream: ${value}");
  }
  print("Done");

  // ---------------------------------------------------------------------------
  // TEST 2: create a broadcast stream.
  // ---------------------------------------------------------------------------

  // If several listeners want to listen to a single subscription stream, use
  // asBroadcastStream to create a broadcast stream on top of the non-broadcast
  // stream.
  print("Create a broadcast stream. Note that it does not start to emit values until it gets assigned a listener.");
  s = Container.streamer().asBroadcastStream();
  print("Wait 5 seconds to show that the emission has not started yet.");

  // Note: now the stream is assigned a listener! So it starts emitting values.
  // This listener listens **for the first value ONLY**.
  s.length.then((int value) => print("Length: $value"));
  // The stream is assigned another listener!
  // This listener listens **for the number of values ONLY**.
  s.first.then((int value) => print("First: $value"));
  // The stream is assigned another listener!
  // This listener listens **for the last value ONLY**.
  s.last.then((int value) => print("Last: $value"));
}


