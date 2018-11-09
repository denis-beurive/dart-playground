// This script illustrates the use of stream controllers.
// A stream controller provides a stream. The controller user can interact with
// the stream through the stream controller API.

import 'dart:async';
import 'dart:io';

/// This class encapsulates all the necessary data used by the "onValue" event
/// handler (the construct avoids using global variables).
class OnValueHandlerContainer {
  static StreamSubscription<int> _streamSubscriber;

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
    print("An event has been raised. The associated value is ${value}!");
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

main() async {

  // Create a controller.
  // A StreamController gives you a new stream and a way to add events to the stream
  // at any point, and from anywhere. The stream has all the logic necessary to handle
  // listeners and pausing. You return the stream and keep the controller to yourself.
  StreamController<int> sc = StreamController<int>(
      onListen: () => print("The stream has been assigned a listener!"),
      onCancel: () => print("The stream has been canceled!"),
      onPause:  () => print("The stream has been paused!"),
      onResume: () => print("The stream has been resumed!")
  );

  // Get the stream created by the stream controller.
  // Right now, this stream has no assigned listener.
  Stream<int> stream = sc.stream;
  print("Does the controller have a listener ? ${sc.hasListener ? 'yes' : 'no'}");

  // Add a listener to the stream.
  // Now the stream has an assigned listener.
  StreamSubscription<int> subscriber = stream.listen(OnValueHandlerContainer.onValue);
  OnValueHandlerContainer.setStreamSubscriber(subscriber);
  print("Does the controller have a listener ? ${sc.hasListener ? 'yes' : 'no'}");

  // Push a value into the stream controlled by the stream controller.
  sc.add(10);

  for(int i=0; i<5; i++) {
    print("Wait 1 second and then send the value ${i}.");
    sleep(Duration(seconds: 1));
    sc.add(i);
  }

  // WARNING: if you think that you can resume the subscription here... then you
  // are wrong. The "onData" event handler may not have started to execute. Thus,
  // the subscription may not have been paused yet.
  // Conclusion: resuming the subscription here may have no effect.

  // If you cancel the subscription now... the "onData" event handler may never
  // be executed.

  print("End");

  // As you may note, the "onData" event handler may execute after the last print.
}