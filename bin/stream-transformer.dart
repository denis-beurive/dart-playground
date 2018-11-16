// Conceptually, a transformer is simply a function from Stream to Stream that
// is encapsulated into a class.

import 'dart:async';

/// This class defines the implementation of a class that emulates a function
/// that converts a data with a given type (S) into a data with another type (T).
abstract class TypeCaster<S, T> {
  T call(S value);
}

/// This class emulates a converter from integers to strings.
class Caster extends TypeCaster<int, String> {
  String call(int value) {
    return "<${value.toString()}>";
  }
}

// StreamTransformer<S, T> is an abstract class. The functions listed below must
// be implemented:
// - Stream<T> bind(Stream<S> stream)
// - StreamTransformer<RS, RT> cast<RS, RT>()

class CasterTransformer<S, T> implements StreamTransformer<S, T> {

  StreamController<T> _controller;
  bool _cancelOnError;
  TypeCaster<S, T> _caster;

  // Original (or input) stream.
  Stream<S> _stream;

  // The stream subscription returned by the call to the function "listen", of
  // the original (input) stream (_stream.listen(...)).
  StreamSubscription<S> _subscription;

  CasterTransformer(TypeCaster<S, T> caster, {
    bool sync: false,
    bool cancelOnError: true
  }) {
    _controller = new StreamController<T>(
        onListen: _onListen,
        onCancel: _onCancel,
        onPause: () => _subscription.pause(),
        onResume: () => _subscription.resume(),
        sync: sync
    );
    _cancelOnError = cancelOnError;
    _caster = caster;
  }


  CasterTransformer.broadcast(TypeCaster<S, T> caster, {
    bool sync: false,
    bool cancelOnError: true
  }) {
      _cancelOnError = cancelOnError;
      _controller = new StreamController<T>.broadcast(
          onListen: _onListen,
          onCancel: _onCancel,
          sync: sync
      );
      _caster = caster;
  }

  /// Handler executed whenever a listener subscribes to the controller's stream.
  void _onListen() {
    _subscription = _stream.listen(
        onData,
        onError: _controller.addError,
        onDone: _controller.close,
        cancelOnError: _cancelOnError
    );
  }

  /// Handler executed whenever the subscription to the controller's stream is cancelled.
  void _onCancel() {
    _subscription.cancel();
    _subscription = null;
  }

  /// Handler executed whenever data comes from the original (input) stream.
  /// Please note that the transformation takes place here.
  void onData(S data) {
    _controller.add(_caster(data));
  }

  /// This method is called once, when the stream transformer is assigned to the
  /// original (input) stream. It returns the stream provided by the controller.
  /// Note: here, you can see that the process transforms a value of type
  ///       S into a value of type T. Thus, it is necessary to provide a function
  ///       that performs the conversion from type S to type T.
  /// Note: the returned stream may accept only one, or more than one, listener.
  ///       This depends on the method called to instantiate the transformer.
  ///       * CasterTransformer() => only one listener.
  ///       * CasterTransformer.broadcast() => one or more listener.
  Stream<T> bind(Stream<S> stream) {
    _stream = stream;
    return _controller.stream;
  }

  // TODO: what should this method do ? Find the answer.
  StreamTransformer<RS, RT> cast<RS, RT>() {
    return StreamTransformer<RS, RT>((Stream<RS> stream, bool b) {
      // What should we do here ?
    });
  }
}


main() {

  // ---------------------------------------------------------------------------
  // TEST: unicast controller.
  // ---------------------------------------------------------------------------

  // Create a controller that will be used to inject integers into the "input"
  // stream.
  StreamController<int> controller_unicast = new StreamController<int>();
  // Get the stream "to control".
  Stream<int> integer_stream_unicast = controller_unicast.stream;
  // Apply a transformer on the "input" stream.
  // The method "transform" calls the method "bind", which returns the stream that
  // receives the transformed values.
  Stream<String> string_stream_unicast = integer_stream_unicast.transform(CasterTransformer<int, String>(new Caster()));

  string_stream_unicast.listen((data) {
    print('String => $data');
  });

  // Inject integers into the "input" stream.
  controller_unicast.add(1);
  controller_unicast.add(2);
  controller_unicast.add(3);

  // ---------------------------------------------------------------------------
  // TEST: broadcast controller.
  // ---------------------------------------------------------------------------

  StreamController<int> controller_broadcast = new StreamController<int>.broadcast();
  Stream<int> integer_stream_broadcast = controller_broadcast.stream;
  Stream<String> string_stream_broadcast = integer_stream_broadcast.transform(CasterTransformer<int, String>.broadcast(new Caster()));

  string_stream_broadcast.listen((data) {
    print('Listener 1: String => $data');
  });

  string_stream_broadcast.listen((data) {
    print('Listener 2: String => $data');
  });

  controller_broadcast.add(1);
  controller_broadcast.add(2);
  controller_broadcast.add(3);
}

