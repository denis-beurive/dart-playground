# Synchronous iterators

A synchronous iterator is just an object, bound to a function, that generates values "on demand". Each time the user
(of the iterator) requests the next value from the iterator, the function is executed. The value returned by the function
is returned to the user. Please note that the returned value may be produced "at the time of the call". One uses case of
synchronous iterators could be to gather environmental data. In this case the iterator's function could be seen as a kind
of probe.

# Creating a synchronous iterator

The code below creates a synchronous iterator that will generate a given number of values.

> Note : the function `mySynchronousIterator()` executes synchronously. Each generated value is created immediately.

    Random randomGenerator = Random.secure();
    
    /// This function returns a synchronous Iterator.
    /// This iterator will synchronously generate a pre-defined number of values.
    /// [count] represents the number of values to generate.
    Iterable<int> mySynchronousIterator(int count) sync* {
      print("Initialize a synchronous iterator for ${count} items");
      for(int i=0; i<count; i++) {
        int v = randomGenerator.nextInt(100);
        print("Generate the new value ${v}");
        yield v;
      }
    } 

> Please note the use if the keywords "`sync*`" and "`yield`".
>
> * "async" creates a Future.
> * "async*" creates a Stream.
> * "sync*" creates a synchronous iterator.

# Using the synchronous iterator

    Iterable<int> iterator = mySynchronousIterator(10);

    int n = 1;
    iterator.forEach((int v) {
        print("- [${n++}] The value ${v} was extracted from the iterator");
    });

# Examples

[Synchronous generator](https://github.com/denis-beurive/dart-playground/blob/master/bin/synchronous-generator.dart)


