// This script illustrates the use of a broadcast stream.
//
// A broadcast stream can have more than one subscriber. Each subscriber gets
// notified when an event is sent through the stream.

import 'dart:async';
import 'package:dart_playground/stream_container_creator.dart';

const int eventsCount = 10;
const int wait_between_two_events = 1;

main() async {

  StreamContainerCreator container = StreamContainerCreator(
      count: eventsCount,
      wait: wait_between_two_events
  );

  // Create 2 subscribers.
  var subscriber1 = (value) => print("Subscriber 1 => ${value}");
  var subscriber2 = (value) => print("Subscriber 2 => ${value}");

  // Create a stream that will broadcast a total of "eventsCount" events.
  // "wait_between_two_events" seconds will be waited between 2 events.
  Stream<int> stream = container.getStream().asBroadcastStream();

  // Please note that the stream does not start to generate events until at least
  // one subscriber subscribes to it.
  StreamSubscription<int> subscription1 = stream.listen(subscriber1); // First subscription.
  StreamSubscription<int> subscription2 = stream.listen(subscriber2); // Second subscription.

  // Wait for the two subscribers to terminate.
  await Future.wait(
      [
        subscription1.asFuture<int>(),
        subscription2.asFuture<int>()
      ]).then((List<int> list) {
        print("The stream closed!");
      });

  // See: https://api.dartlang.org/stable/2.0.0/dart-async/StreamSubscription/cancel.html
  //      The stream may need to shut down the source of events and clean up
  //      after the subscription is canceled. Returns a future that is completed
  //      once the stream has finished its cleanup.
  subscription1.cancel();
  subscription2.cancel();

  print("End of script");
}
