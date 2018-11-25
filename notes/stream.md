# Streams

Basically, a stream can be seen as a FIFO that propagates _values_ from a _publisher_
to at least one _subscriber_.

By subscribing to a stream, a _subscriber_ gets notified whenever a value is available
in the stream. In other words, it gets notified "in the event" of a value being available.
Yet another way to say it is: a _subscriber_ "listens" to _events_ (which are notifications of
availability). This explains why _subscribers_ may also be called _(event) listeners_.

> For those who work with brokers (such as RabbitMQ, ZeroMQ...), the term "subscriber" may be the one that springs to mind first.
> For those who come from the JavaScript world, it would be the term "event listener", or "event handle".

The association between a _subscriber_ and a _stream_ is called a _subscription_.
A _subscription_ can be:

* **cancelled**: once the _subscription_ is cancelled, the _subscriber_ does not receive any more notification.
  Please note that the cancellation is irreversible. Once the subscription is cancelled,
  the stream is (asynchronously) destroyed.
* **paused**: Once the subscription is paused, the subscriber does not receive any more notification until the subscription
  is resumed. Please note that a pause is reversible (by contrast with the cancellation).
  While the subscription is paused, events are stored.
* **resumed**: a previously paused subscription may be resumed. When a subscription is resumed, the subscriber gets notified
  of the events again.

Streams can be classified into two groups:

* **unicast streams**: unicast streams propagates events from one publisher to one (and only one) subscriber.
* **broadcast streams**: broadcast streams propagates events from one publisher to one or more subscribers.

# Creating a stream

On way to create a stream is to write a function that "injects" values into the stream.

> To designate the process of "feeding" the stream with values, Dart does not use the verb "to inject", it uses the verb "to yield".
> In French, "yield" translates into "céder". This translation may be interesting for French readers.

Please note that values are "yielded" as they become available.
This means that the function that implements the publisher cannot return a result immediately.
Thus, this function must execute asynchronously.

Example:

    import 'dart:async';

    typedef Streamer = Stream<int> Function();

    main() async {

        /// Return a stream of integers.
        Streamer streamCreator = () async* {
            for(int i=0; i<10; i++) {
                yield 3*i;
                sleep(Duration(seconds: 1));
            }
        };

        Stream<int> stream = streamCreator();
    }

> Please note the use of the keywords `async*` and `yield`.

# Subscribing to a stream

    StreamSubscription<int> subscription = streamCreator().listen(
        (int value) => print("A value is available: ${value}.")
    );

In this example we set a (event) handler, implemented by an anonymous function, that will be fired up whenever a value
is available in the stream.

> Please note that as soon this code is executed, the script continues its execution. The instructions that follow may well
> be (and will be) executed before the handler gets executed.

Please note that there are other ways to subscribe to a stream.

# Waiting for a value to be available

Sometimes it is necessary to block the execution of the script until a value gets available.

    await for(int value in streamCreator()) {
        (value) => print("A value is available: ${value}.")
    }
    print("Done");

The last instruction (`print("Done")`) will not be executed until the stream dries up.

Another way to wait for a stream to dry up:

    await streamCreator().forEach(
        (int value) => print("A value is available: ${value}.")
    ).then((var v) { print("Done"); });

And yet another way:

    StreamSubscription<int> subscription = streamCreator().listen(
        (int value) => print("A value is available: ${value}.")
    );
    await Future.wait([subscription.asFuture<int>()]).then((List<int> value) {
        print("Done");
    });

# Examples

* [Unicast streams](https://github.com/denis-beurive/dart-playground/tree/master/bin/stream-unicast.dart)
* [Broadcast streams](https://github.com/denis-beurive/dart-playground/tree/master/bin/stream-broadcast.dart)

And:

* [Stream transformers](https://github.com/denis-beurive/dart-playground/tree/master/bin/stream-transformer.dart)
* [Stream controller](https://github.com/denis-beurive/dart-playground/tree/master/bin/stream-controller.dart)



