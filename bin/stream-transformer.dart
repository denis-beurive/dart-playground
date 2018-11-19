// Conceptually, a transformer is simply a function from Stream to Stream that
// is encapsulated into a class.
//
// A transformer is made of:
// - A stream controller. The controller provides the "output" stream that will
//   receive the transformed values.
// - A "bind()" method. This method is called by the "input" stream "transform"
//   method (inputStream.transform(<the stream transformer>).

import 'dart:async';

/// This class defines the implementation of a class that emulates a function
/// that converts a data with a given type (S) into a data with another type (T).
abstract class TypeCaster<S, T> {
  T call(S value);
}

/// This class emulates a converter from integers to strings.
class CasterInt2String extends TypeCaster<int, String> {
  String call(int value) {
    return "<${value.toString()}>";
  }
}

/// This class emulates a converter from any numerical values to strings.
class CasterNum2String extends TypeCaster<num, String> {
  String call(num value) {
    // We could perform some sanity checks here...
    return value.toString();
  }
}

// StreamTransformer<S, T> is an abstract class. The functions listed below must
// be implemented:
// - Stream<T> bind(Stream<S> stream)
// - StreamTransformer<RS, RT> cast<RS, RT>()

class CasterTransformer<S, T> implements StreamTransformer<S, T> {

  StreamController<T> _controller;
  bool _cancelOnError;
  TypeCaster _caster;
  /// This caster is used in conjunction with the method call.
  /// it is used to instantiate a new transformer that accepts different (and
  /// incompatible) input/output data types.
  TypeCaster _newCaster;

  // Original (or input) stream.
  Stream<S> _stream;

  // The stream subscription returned by the call to the function "listen", of
  // the original (input) stream (_stream.listen(...)).
  StreamSubscription<S> _subscription;

  /// Constructor that creates a unicast stream.
  /// [caster] An instance of "type caster".
  CasterTransformer(TypeCaster caster, {
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

  /// Constructor that creates a broadcast stream.
  /// [caster] An instance of "type caster".
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
  /// Note: when the transformer is applied to the original stream, through call
  ///       to the method "transform", the method "bind()" is called behind the
  ///       scenes. The method "bind()" returns the controller stream.
  ///       When a listener is applied to the controller stream, then this function
  ///       (that is "_onListen()") will be executed. This function will set the
  ///       handler ("_onData") that will be executed each time a value appears
  ///       in the original stream. This handler takes the incoming value, casts
  ///       it, and inject it to the (controller) output stream.
  /// Note: this method is called only once. On the other hand, the method "_onData"
  ///       is called as many times as there are values to transform.
  void _onListen() {
    _subscription = _stream.listen(
        _onData,
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
  /// Note: this method is called as many times as there are values to transform.
  void _onData(S data) {
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

  /// Set a new caster function.
  /// [caster] represents the new caster function.
  /// Please note that this method is used in conjunction with the method call.
  void setNewCaster(TypeCaster caster) {
    _newCaster = caster;
  }

  // This method is used when you need to use an already instantiated transformer
  // to perform a transformation on data incompatible with its input/output data
  // types. This method just instantiate a new transformer that accepts the new
  // input/output data types.
  CasterTransformer<RS, RT> cast<RS, RT>() {
    return CasterTransformer<RS, RT>(_newCaster);
  }
}


main() {

  // ---------------------------------------------------------------------------
  // TEST: unicast controller.
  // ---------------------------------------------------------------------------

  // Create a controller that will be used to inject integers into the "input"
  // stream.
  StreamController<int> intControllerUnicast = new StreamController<int>();
  // Get the stream "to control".
  Stream<int> intStreamUnicast = intControllerUnicast.stream;
  // Apply a transformer on the "input" stream.
  // The method "transform" calls the method "bind", which returns the stream that
  // receives the transformed values.
  Stream<String> stringStreamUnicast = intStreamUnicast.transform(CasterTransformer<int, String>(new CasterInt2String()));

  stringStreamUnicast.listen((data) {
    print('String => $data');
  });

  // Inject integers into the "input" stream.
  intControllerUnicast.add(1);
  intControllerUnicast.add(2);
  intControllerUnicast.add(3);

  // ---------------------------------------------------------------------------
  // TEST: broadcast controller.
  // ---------------------------------------------------------------------------

  StreamController<int> intControllerBroadcast = new StreamController<int>.broadcast();
  Stream<int> intStreamBroadcast = intControllerBroadcast.stream;
  Stream<String> stringStreamBroadcast = intStreamBroadcast.transform(CasterTransformer<int, String>.broadcast(new CasterInt2String()));

  stringStreamBroadcast.listen((data) {
    print('Listener 1: String => $data');
  });

  stringStreamBroadcast.listen((data) {
    print('Listener 2: String => $data');
  });

  intControllerBroadcast.add(1);
  intControllerBroadcast.add(2);
  intControllerBroadcast.add(3);

  // ---------------------------------------------------------------------------
  // TEST: cast()
  // ---------------------------------------------------------------------------

  // Get a stream that accepts numerical values.
  // Please note that an integer is a numerical value.
  StreamController<num> numControllerUnicast = new StreamController<num>();
  Stream<num> numStreamUnicast = numControllerUnicast.stream;

  // We could have instantiated a transformer that transforms numerical values
  // into strings (this should have implied the creation of a new "type caster").
  // However, for the sake of this example, we voluntarily create a transformer
  // that transforms integers to strings.
  CasterTransformer<int, String> int2stringTransformer = CasterTransformer<int, String>(new CasterInt2String());

  // Since a numerical value may not be an integer, the created transformer cannot
  // be used to transform the values extracted from the stream "num_stream_unicast".
  // => We "cast" the transformer "int2stringTransformer" into a transformer suitable
  // for our needs (that is, a transformer that accepts numerical values as input).
  int2stringTransformer.setNewCaster(CasterNum2String());
  CasterTransformer<num, String> num2stringTransformer = int2stringTransformer.cast<num, String>();

  Stream<String> newStringStreamUnicast = numStreamUnicast.transform(num2stringTransformer);
  newStringStreamUnicast.listen((String value) => print("Got the value ${value}!"));

  numControllerUnicast.add(10);
  numControllerUnicast.add(20);
  numControllerUnicast.add(30.12);

}

