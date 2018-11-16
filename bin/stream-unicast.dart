// This script illustrates the use of a unicast stream.
//
// Basically, a stream can be seen as a FIFO that propagates events from a publisher
// to at least one subscriber. Streams can be classified into two groups:
//
// - unicast streams. Unicast streams propagates events from one publisher to one
//   (and only one) subscriber.
// - broadcast streams. Broadcast streams propagates events from one publisher to
//   one or more subscribers.
//
// Please note that the techniques described in this document can also be used
// for broadcast streams.

import 'dart:io';
import 'dart:async';
import 'package:dart_playground/stream_container_creator.dart';

const int eventsCount = 5;
const int waitBetweenTwoEvents = 1;

// We use "typedef" to describe the signature of a function that creates a stream.
typedef Streamer = Stream<int> Function();

main() async {

  // ---------------------------------------------------------------------------
  // TEST: create a stream and wait for it to close.
  // ---------------------------------------------------------------------------

  Streamer streamCreator = () async* {
    for(int i=0; i<eventsCount; i++) {
      yield 3*i;
      sleep(Duration(seconds: waitBetweenTwoEvents));
    }
  };

  // One way to get all the values fired in the stream:
  await for(int value in streamCreator()) {
    print("[1] An event has been received. The value is ${value}.");
  }
  print("Done");

  // Another way to get all the values fired in the stream:
  await streamCreator().forEach((int value) {
    print("[2] An event has been received. The value is ${value}.");
  }).then((var v) { print("Done"); });

  // Another way to get all the values fired in the stream:
  StreamSubscription<int> subscription = streamCreator().listen(
          (value) => print("[3] An event has been received. The value is ${value}.")
  );
  await Future.wait([subscription.asFuture<int>()]).then((List<int> value) {
    print("Done");
  });

  // See: https://api.dartlang.org/stable/2.0.0/dart-async/StreamSubscription/cancel.html
  //      The stream may need to shut down the source of events and clean up
  //      after the subscription is canceled. Returns a future that is completed
  //      once the stream has finished its cleanup.
  subscription.cancel();

  // ---------------------------------------------------------------------------
  // TEST: skip the N first events within the stream.
  // ---------------------------------------------------------------------------

  Stream<int> stream = streamCreator();
  Stream<int> shiftedStream = stream.skip(2);

  await for(int value in shiftedStream) {
    print("[4] An event has been received. The value is ${value}.");
  }
  print("Done");

  // ---------------------------------------------------------------------------
  // TEST: keep only some of the values within the stream.
  // ---------------------------------------------------------------------------

  StreamContainerCreator container = StreamContainerCreator();
  stream = container.getStream();
  Stream<int> filteredStream = stream.where((int value) => value > 10);
  Future<int> count_greater_that_ten = filteredStream.length.then((int value) { return value; } );
  count_greater_that_ten.then((int value) {
    if (container.getGreaterThanTen() == value) {
      print("SUCCESS");
    } else {
      print("ERROR");
    }
  });

  // ---------------------------------------------------------------------------
  // TEST: perform a given action upon all values within the stream.
  // ---------------------------------------------------------------------------

  stream = streamCreator();
  Stream<int> doubledStream = stream.map((int value) => 2*value);
  await doubledStream.forEach((int value) => print("[5] An event has been received. The value is ${value}."))
      .then((var v) => print("Done"));

  // ---------------------------------------------------------------------------
  // TEST: stop processing when the first value that verifies a given condition
  //       is found. Please note that the stream may not close right after that
  //       the first integer greater than 10 is detected. We don't know when the
  //       condition (on values) is evaluated, since it depends on many
  //       parameters. Thus, the condition may well be evaluated after the first
  //       integer that is greater than 10 has been generated.
  // ---------------------------------------------------------------------------

  container = StreamContainerCreator(count: 10);
  Future<bool> alert = container.getStream().any((int value) => value > 10);
  await alert.then((bool value) => print("One value greater than 10 has been found (${value ? 'true' : 'false'})."));

  // ---------------------------------------------------------------------------
  // TEST: discard all events, but signal when the stream closes.
  // ---------------------------------------------------------------------------

  container = StreamContainerCreator(count: 10);
  await container.getStream().drain().then((var value) => print(value));

  // ---------------------------------------------------------------------------
  // TEST: get the Nth event that is fired.
  // ---------------------------------------------------------------------------

  container = StreamContainerCreator(count: 10);
  await container.getStream().elementAt(3).then((int value) => print("Got the third event!"));

  // ---------------------------------------------------------------------------
  // TEST: test whether all values verify a given constraint.
  // ---------------------------------------------------------------------------

  container = StreamContainerCreator(count: 10);
  await container.getStream().every((int value) => value > 0).then((bool value) {
    print("Value is ${value ? 'true' : 'false'}");
    if (value) {
      print("All values are greater that 0.");
    } else {
      print("All values are not greater that 0.");
    }
  });


  print("End of script");
}