# Futures

A "Future" is an object returned by a function that executes asynchronously.
When a "Future" is created, the asynchronous function that is responsible for
initialising it may not be terminated yet. Therefore, when it's created, the
Future is not complete. It will be complete (and so, ready to be used)
at some point in the future (once the asynchronous function terminates its
execution).

The notation "`Future<int> object`" means: in the future, the object will be an integer.

# Creating Futures

There are two ways for creating a Future. You can use the keyword "async", or you can explicitly create a Future using
the Future API. 

## Using the keyword "async"

The function below creates a "future integer":

    /// Double a given value asynchronously.
    /// [in_value] represents the value to double.
    /// The function immediately returns an object, which is a Future.
    /// This Future will not be complete after at least one second (may be more).
    /// Please note the use of the keyword "async".
    Future<int> sleep_and_double(int in_value) async {
        sleep(Duration(seconds: 1));
        return 2*in_value;
    }

> Please note the use of the keyword "`async`".
>
> * "async" creates a Future.
> * "async*" creates a Stream.

## Explicitly returning a Future

    /// Double a given value asynchronously.
    /// [in_value] represents the value to double.
    /// The function immediately returns an object, which is a Future.
    /// This Future will not be complete after at least 3 seconds (may be more).
    Future<int> another_sleep_and_double(int value) {
        return Future(() {
            sleep(Duration(seconds: 3));
            return 2*value;
        });
    } 

# Using the Future when it completes

    Future<int> v = sleep_and_double(10);

    v.then(
          (int value) => print("The asynchronous function sleep_and_double() finally returned! The returned value is ${value}")
          // This callback function returns null.
          // However, it could return a Future.
    );

Or:

    sleep_and_double(10).then(
          (int value) => print("The asynchronous function sleep_and_double() finally returned! The returned value is ${value}")
    );

# Wait for a Future to complete

    Future<int> sleep_and_triple(int in_value, [int duration=1]) async {
      sleep(Duration(seconds: duration));
      return 3*in_value;
    }

    print("Wait 4 seconds...");
    int value = await sleep_and_triple(10, 4);
    print("Done. Value is ${value}");

This code `print("Done. Value is ${value}")` will not be executed until the Future returned by function `sleep_and_triple()`
is complete.

# Wait for multiple Futures to complete

    Future.wait([sleep_and_double(10), sleep_and_triple(10, 2)]).then((List<int> list) {
        print('The 2 asynchronous calls terminated! The returned values are:');
        list.forEach((int value) => print("> Value ${value}"));
    });
    print("Done");

The code `print("Done")` will not be executed until the two Futures returned by the functions `sleep_and_double()` and
`sleep_and_triple()`  complete.

# What is FutureOr<T>?

How to interpret this signature ?

    Future<T>.delayed(Duration duration, [ FutureOr<T> computation() ])

This means that the function "computation" must return an object which type can be: `Future<T>` or `T`.

* If the function returns a value of type `T`, then the value will be automatically wrapped into a Future.
* If the function returns a value of type "Future<T>", then the value will be returned "as such".

`FutureOr<T> computation()` returns `T` (in this case, an integer):

    Future<int> f1 = Future.delayed(Duration(seconds: 1), () => 10);
    f1.then((int value) => print(Colorize("[9] -> ${value}")..lightRed()));

`FutureOr<T> computation()` returns `Future<T>`:

    Future<int> f2 = Future.delayed(Duration(seconds: 1), () => Future<int>(() => 10));
    f2.then((int value) => print(Colorize("[10] -> ${value}")..lightGreen()));

The result is the same.

Please note that if you create an object that includes "Futures inside Futures" (like Russian dolls), the resulting value
is a "simple Future". The Dart VM removes peels "the onions" (removes the useless layers of Futures encapsulation). For example:

    Future<int> f3 = Future.delayed(Duration(seconds: 1), () => Future<int>(() => Future<int>(() => 10)));
    f3.then((int value) => print(Colorize("[10] -> ${value}")..lightRed()));

# Examples

[Futures](https://github.com/denis-beurive/dart-playground/blob/master/bin/future.dart)

