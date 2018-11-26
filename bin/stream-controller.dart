// This script illustrates the use of stream controllers.
//
// A stream controller provides a stream. The controller user can interact with
// the stream through the stream controller API. In particular, it is possible
// to inject events into the stream, through the controller API. It is interesting
// to point out that more than one entity can inject data into the stream provided
// by the controller.
//
// See: https://webdev.dartlang.org/articles/performance/event-loop

import 'dart:async';
import 'dart:io';

/// This class encapsulates all the necessary data used by the "onValue" event
/// handler (the construct avoids using global variables).
class OnValueHandlerContainer {
  static StreamSubscription<int> _streamSubscription;

  static setStreamSubscription(StreamSubscription<int> stream) {
    _streamSubscription = stream;
  }

  // This static method is the handler executed when a event is received through
  // the stream.
  //
  // WARNING: you have absolutely no idea when this handler will be executed.
  // Do not assume that it will be executed right after the execution of the code
  // that emits an event. It may be executed several lines (of codes) below the
  // line that emits the event. It may well be executed after the end of the
  // script.
  static void onValue(int value) {
    // At this point: the state of the subscription is (inevitably) "active".
    print("onValue: An event has been raised. The associated value is ${value}!");
    print("         Pause the subscription. Wait for 1 second. Resume the subscription");

    // Note 1: once a Dart function starts executing, it continues executing until
    //         it exits. When managing interrupts in C, it is necessary to protect
    //         interrupt handlers from being interrupted. This is not the case in
    //         Dart : a function (and, thus, an event handler) cannot be interrupted
    //         by the occurrence of another event.
    //         => The code below has no sense, other than experimentation.
    // Note 2: while paused, the subscription will not fire any events. If it receives
    //         events from its source, they will be buffered until the subscription
    //         is resumed.
    _streamSubscription.pause();
    sleep(Duration(seconds: 1));
    _streamSubscription.resume();

    // At this point: the state of the subscription is "active".
  }
}

main() async {

  // Create a controller.
  // A StreamController gives you a new stream and a way to add events to the stream
  // at any point, and from anywhere. The stream has all the logic necessary to handle
  // listeners and pausing. You return the stream and keep the controller to yourself.
  StreamController<int> sc = StreamController<int>(
      onListen: () => print("Controller: the stream has been assigned a listener/subscriber!"),
      onCancel: () => print("Controller: the stream has been canceled!"),
      // As you may notice, the event handlers are not executed every time the
      // subscription gets paused or resumed.
      //
      // This behaviour comes from these facts:
      // - Dart is single-threaded.
      // - An event handler cannot be interrupted: once a Dart function starts
      //   executing, it continues executing until it exits. In other words, Dart
      //   functions can’t be interrupted by other Dart code.
      //   See https://webdev.dartlang.org/articles/performance/event-loop
      // - A stream is a FIFO.
      onPause:  () => print("Controller: the stream has been paused!"),
      onResume: () => print("Controller: the stream has been resumed!")
  );

  // Get the stream created by the stream controller.
  // Right now, this stream has no assigned listener.
  Stream<int> stream = sc.stream;
  print("Does the stream provided by the controller have a listener ? ${sc.hasListener ? 'yes' : 'no'} - the answer should be no.");

  // Push values into the stream controlled by the stream controller.
  // Because no listener subscribed to the stream, these values are just stored
  // into the stream.
  // WARNING: according to the great answer provided on the link below, you should
  //          not inject data into the stream before a listener subscribes to it.
  // See: https://stackoverflow.com/questions/53336297/cli-dart-onpause-onresume-ondone-not-firing-up-as-expected
  for(int i=0; i<3; i++) {
    print("Send the value ${i} into the stream.");
    sc.add(i);
  }

  // Add a listener to the stream.
  // Now the stream has an assigned listener.
  StreamSubscription<int> subscription = stream.listen(OnValueHandlerContainer.onValue);
  OnValueHandlerContainer.setStreamSubscription(subscription);
  subscription.onDone(() => print("The subscription is done!"));
  // Please note that it is necessary to close the stream controller in order to
  // close "its" stream. The closing does not take effect immediately... The
  // controller closes when it can do it. If you don't close the controller, the
  // "onDone" handler will not be executed.
  // See: https://stackoverflow.com/questions/53336297/cli-dart-onpause-onresume-ondone-not-firing-up-as-expected
  sc.close().then((var v) => print("The stream controller is now closed"));
  print("Does the stream provided by the controller have a listener ? ${sc.hasListener ? 'yes' : 'no'} - the answer should be yes.");

  // Wait for 10 seconds.
  print("Start waiting for 10 seconds");
  Future.delayed(Duration(seconds: 10)).then((var v) => print("10 seconds ellapsed!"));
  print("End of script");
}