// This package implements a stream creator container.
//
// A stream creator container is just a class that encapsulates that data needed
// by the stream creator to run. The method that creates the stream is "getStream".

import 'dart:math';
import 'dart:async';
import 'dart:io';

/// This class encapsulates the data used by stream creator container.
class StreamContainerCreator {
  static Random _random_generator = Random(123);
  int _events_count;
  String _name;
  int _wait_between_events;
  int _count_greater_than_ten;
  int _total_count;

  /// Build a StreamContainer.
  /// [count]: the number of events to generate.
  /// [name]: the name of the stream.
  /// [wait]: number of seconds to wait between two events.
  StreamContainerCreator({int count=2, String name='', int wait=1}) {
    _events_count = count;
    _name = name;
    _wait_between_events = wait;
  }

  /// Set the number of events to generate.
  /// [count]: the number of events to generate.
  StreamContainerCreator setCount(int count) {
    _events_count = count;
    return this;
  }

  /// Set the name of the stream.
  /// [name]: the name of the stream.
  StreamContainerCreator setName(String name) {
    _name = name;
    return this;
  }

  /// Set the number of seconds to wait between two events.
  /// [wait] number of seconds to wait between two events.
  StreamContainerCreator setWait(int wait) {
    _wait_between_events = wait;
    return this;
  }

  /// This method creates a stream of integers.
  Stream<int> getStream() async* {
    _count_greater_than_ten = 0;
    _total_count = 0;
    String prefix = _name != '' ? "[${_name}] " : '';
    for (int i=0; i<_events_count; i++) {
      _total_count++;
      int v = _random_generator.nextInt(10) + _random_generator.nextInt(10);
      print("${prefix}Wait ${_wait_between_events} seconds and then generate the value ${v} (${_total_count}/${_events_count})");
      sleep(Duration(seconds: _wait_between_events));
      if (v > 10) { _count_greater_than_ten++; }
      yield v;
    }
  }

  // Return the number of integers which values are greater than ten that have
  // been generated.
  int getGreaterThanTen() {
    return _count_greater_than_ten;
  }
}