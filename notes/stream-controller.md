# Stream controller

A stream controller provides a stream. The controller user can interact with the stream through the stream controller API.
In particular, it is possible to inject events into the stream, through the controller API.

It is interesting to point out that more than one entity can inject data into the stream provided by the controller.
Stream controllers can be used to build a "multi-publisher / multi-subscriber" architecture.  

# Using controllers

Typically, you create a controller and then you retrieve the stream that was automatically created by the controller.

    StreamController<int> sc = StreamController<int>(
          onListen: () => print("Controller: the stream has been assigned a listener/subscriber!"),
          onCancel: () => print("Controller: the stream has been canceled!"),
          onPause:  () => print("Controller: the stream has been paused!"),
          onResume: () => print("Controller: the stream has been resumed!")
    );
      
    Stream<int> stream = sc.stream;

Then, you subscribe a listener to the stream:

    StreamSubscription<int> subscription = stream.listen((int value) => print("${value}");

You can then inject values into the stream that you got from the controller.

    for(int i=0; i<3; i++) {
        sc.add(i); // i is injected into the stream.
    }

And don't forget to close the controller !

    sc.close().then((var v) => print("The stream controller is now closed"));

> **Important note**: when you call the method "close" on a controller, **the controller is not closed immediately**.
The call to the method "close" tells the controller to close itself, "when it is not used anymore".
This method returns a Future that will complete when the closing operation is effective.

# Examples

[Controllers](https://github.com/denis-beurive/dart-playground/blob/master/bin/stream-controller.dart)





    
