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
* [Immutability](https://github.com/denis-beurive/dart-playground/blob/master/notes/immutability.md)
* [Types](https://github.com/denis-beurive/dart-playground/blob/master/notes/types.md)

# Tips and tricks

## Suppressing warnings about unused variables 

Sometimes you want to create variables that will not be used. But you don't like these annoying warnings that tell you
that you are doing bad things (namely, that you define unused variables).

> What would you create unused variables? Maybe you are exploring Dart and you just want to play with the syntax.
> Or, maybe these variables are not used yet, but they will be soon.

Whatever your good reason is, here is a trick: you create a function that accepts any variable and that does nothing!

    /// This function is used to let the compiler think that a variable is used while it is not.
    /// This is just a trick to avoid warnings from the compiler/editor.
    /// [v] represents any variable.
    void noop(var v) {}

And you can use it:

    int a;
    int b;
    noop(a);
    noop([a, b]);

