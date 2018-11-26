# Isolates

Isolates can be seen as an "Erlang process", although this comparison is not accurate:

* Isolates never execute simultaneously, in the sense that when an isolate starts running, it is not interrupted unless
  it starts waiting for an asynchronous action to complete (typically `̀await for (int value in stream) { ... }`).
  By contrast with an Erlang application, A Dart script is single-threaded.
* However, Dart adopts the Erlang way for implementing communication between isolates. Isolates don't share memory.
  Isolates exchange messages through _channels_. A _channel_ can be seen as an (unidirectional) FIFO. A _channel_
  has a _sender port_ and a _receiving port_.

> In fact a channel is a stream, in the sense the class [ReceivePort](https://api.dartlang.org/stable/2.1.0/dart-isolate/ReceivePort-class.html) extends the class Stream.

# Creating an isolate

Let say that the isolate "`A`" starts the isolate "`B`".

A typical initialisation process is:

* "`A`" creates a channel. Let's name this channel "`c[B -> A]`". This channel will be used by "`B`" to send messages to "`A`".
  This channel has two ends: one end is dedicated for receiving messages (the "receiver end") and the other end is dedicated
  for sending messages (the "sender end").
* "`A`" keeps the end of the channel "`c[B -> A]`" dedicated for receiving messages for himself.
* "`A`" creates "`B`" and gives "`B`" the end of the channel "`c[B -> A]`" dedicated for sending messages.
* Then, "`A`" waits for "`B`" to send him the end of a (new) channel dedicated for sending data.
* "`B`" creates (another) channel. Let's name this channel "`c[A -> B]`". This channel will be used by "`A`" to send messages to "`B`".
  It keeps the end dedicated for receiving messages for himself, and it sends the other end to "`A`".
* "`A`" (that was waiting for a message from "`B`") receives the "sender end" of the channel created by "`B`" (`"c[A -> B]`").

At this end, there are two channels that connect "`A`" and "`B`":

* One channel is used by "`A`" to send messages to "`B`".
* One channel is used by "`B`" to send messages to "`A`".

Each isolate creates a channel and sends its "sender end" to the other isolate.

# Channels

A channel is a stream: the class [ReceivePort](https://api.dartlang.org/stable/2.1.0/dart-isolate/ReceivePort-class.html) extends the class Stream.

Therefore, you use a channel the same way that you use a stream. See: [notes about streams](https://github.com/denis-beurive/dart-playground/blob/master/notes/stream.md).

# Examples

* [Isolates](https://github.com/denis-beurive/dart-playground/blob/master/bin/isolates.dart)

