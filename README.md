# Description

This project contains test scripts written during my study of the Dart programming language.

# Technical notes

This code has been tested with the version "2.0.0" of the Dart VM:

    $ dart --version
    Dart VM version: 2.0.0 (Unknown timestamp) on "linux_x64"

Make sure to run the command below:

    pub get

> See: https://www.dartlang.org/tools/pub/cmd/pub-get

In order to enable assertions, you must explicitly configure Dart from the command line.
For example:

    dart --enable-asserts bin/isolates.dart

> See: https://www.dartlang.org/guides/language/language-tour#assert

# Notes about the Dart API

* [Futures](https://github.com/denis-beurive/dart-playground/blob/master/notes/future.md)
* [Isolates](https://github.com/denis-beurive/dart-playground/blob/master/notes/isolate.md)
* [Streams](https://github.com/denis-beurive/dart-playground/blob/master/notes/stream.md)
* [Stream controllers](https://github.com/denis-beurive/dart-playground/blob/master/notes/stream-controller.md)
* [Synchronous iterators](https://github.com/denis-beurive/dart-playground/blob/master/notes/synchronous-iterator.md)
