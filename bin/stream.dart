// This script illustrates the use of streams. Streams are like event FIFOs.
// It is possible to subscribe to a stream by listening to it. The listener is
// informed of the arrival of events.
//
// https://www.dartlang.org/tutorials/language/streams
// https://www.dartlang.org/articles/libraries/creating-streams

import 'dart:async';
import 'dart:io';
import 'dart:math';

/// This class encapsulates all the necessary data used by the "onValue" event
/// handler (the construct avoids using global variables).
class OnValueHandlerContainer {
  static StreamSubscription<int> _streamSubscriber;
  static int _count = 0;

  static setStreamSubscriber(StreamSubscription<int> stream) {
    _streamSubscriber = stream;
  }

  // Handler executed when a event is received within the stream.
  //
  // WARNING: you have absolutely no idea when this handler will be executed.
  // Do not assume that it will be executed right after the execution of the code
  // that emits an event. It may be executed several lines (of codes) below the
  // line that emits the event. It may well be executed at the end of the script...

  static void onValue(int value) {
    _count++;
    print("[X] An event has been raised. The associated value is ${value}! Count > ${_count}");
    // Pause the subscription.
    //
    // While paused, the subscription will not fire any events. If it receives
    // events from its source, they will be buffered until the subscription is
    // resumed.
    print("Pause the subscription.");
    _streamSubscriber.pause();
    print("Wait for 1 second and resume the subscription.");
    sleep(Duration(seconds: 1));
    _streamSubscriber.resume();
  }
}

/// This class encapsulates all the necessary data used by stream (the construct
/// avoids using global variables).
class StreamContainer {
  static Random _random_generator = Random(123);
  static int count_ten_and_above = 0;

  // This function creates a stream of integers.
  /// This method creates a stream of integers.
  /// The parameter [count] represents the number of events to emit.
  /// The parameter [prefix] is a string that will be printed at the beginning of each message.
  /// The parameter [duration] represents the number of seconds to wait until the next event.
  static Stream<int> streamer({int count=2, String prefix='', int duration=1}) async* {
    count_ten_and_above = 0;
    prefix = prefix != '' ? "[${prefix}] " : '';
    for (int i=0; i<count; i++) {
      int v = _random_generator.nextInt(10) + _random_generator.nextInt(10);
      print("${prefix}Wait ${duration} seconds and then generate the value ${v}");
      sleep(Duration(seconds: duration));
      if (v > 10) { count_ten_and_above++; }
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
  Stream<int> s = StreamContainer.streamer();
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
  await for (int value in StreamContainer.streamer()) {
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
  s = StreamContainer.streamer(count: 5).asBroadcastStream();
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

  // ---------------------------------------------------------------------------
  // TEST 3: create new streams based on existing ones.
  // ---------------------------------------------------------------------------

  // The new stream should have only one event, since:
  // - The stream "s", from which the new stream is built upon, had 5 events.
  // - 2 events have been consumed: the first one and the last one ("s.first..."
  //   and "s.last...").
  // - From the 3 remaining events, the first 2 ones are not transferred to the
  //   new stream.
  print("Create a new stream based on the existing one.");
  Stream<int> duplicated = s.skip(2);
  duplicated.length.then((int value) {
    assert(1 == value);
    print("The new stream has $value element(s).");
  });

  s = StreamContainer.streamer(count: 5, prefix: 'A');
  print("Create a new stream of integers which values are greater that 10. These stream should contain ${StreamContainer.count_ten_and_above} integers.");
  duplicated = s.where((value) => value > 10);
  duplicated.length.then((value) {
    assert(value == StreamContainer.count_ten_and_above);
    print("The new stream contains $value integers (expected ${StreamContainer.count_ten_and_above}).");
  });

  s = StreamContainer.streamer(count: 5, prefix: 'A');
  Stream<int> mapped = s.map((value) => 2*value);
  await mapped.forEach((value) {
    print("- mapped ${value}");
  });

  // ---------------------------------------------------------------------------
  // TEST 4: subscribing to a stream.
  // ---------------------------------------------------------------------------

  s = StreamContainer.streamer(count: 5, prefix: 'A');
  // Please note the while an event handler is applied to the stream, a subscription
  // handler is returned. The subscription may be paused, resumed or cancelled.
  StreamSubscription<int> subscription = s.listen(OnValueHandlerContainer.onValue);
  OnValueHandlerContainer.setStreamSubscriber(subscription);
}


