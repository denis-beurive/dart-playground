# Futures

A "Future" is an object returned by a function that executes asynchronously.
When a "Future" is created, the asynchronous function that is responsible for
initialising it may not be terminated yet. Therefore, when it's created, the
Future is not complete. It will be complete (and so, ready to be used)
at some point in the future (once the asynchronous function terminates its
execution).

The notation "`Future<int> object`" means: in the future, the object will be an integer.

# Creating Futures

The function below creates a "future integer":

    Future<int> sleep_and_double(int in_value) async {
      sleep(Duration(seconds: 1));
      return 2*in_value;
    }

> Please note the use of the keyword "`async`".
>
> * "async" creates a Future.
> * "async*" creates a Stream.

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

# Examples

[Futures](https://github.com/denis-beurive/dart-playground/blob/master/bin/future.dart)

