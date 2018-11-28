# Immutability const / final

From [Wikipedia](https://en.wikipedia.org/wiki/Immutable_object):

_In object-oriented and functional programming, an immutable object (unchangeable object)
is an object whose state cannot be modified after it is created. This is in contrast
to a mutable object (changeable object), which can be modified after it is created._

Dart defines four levels of immutability:

* immutable **bonds** to (unless otherwise stated) mutable (bound) **objects** that are initialised at **runtime**.
  These objects are declared using the keyword **`final`**.
* immutable **bonds** to immutable (bound) **objects** that are initialised at **compile time**.
  These objects are declared using the keyword **`const`** (of the left side).
* immutable **bonds** to immutable (bound) **objects**, that are initialised at **runtime**.
  These objects are created by using the both keywords **`final`** (to the left side) and **`const`** (to the right side).
* mutable **bonds** to "immutable (bound) objects initialised at **runtime**".
  These objects are declared using the keyword **`const`** (on the right side).

Illustration:

    Map<int, int> a = {};       // "a" is bound to the (anonymous) object {}.
    Map<int, int> b = a;        // "b" is bound to the (named) object "a".
    
    final Map<int, int> c = a;  // the bond between "c" and "a" is immutable. However, you can change the "content" of "a".
    c[10] = 100;                // this is OK. The bound object is mutable.
    a[10] = 100;                // this is OK. The bound object is mutable.
    c = {};                     // **this is WRONG** (compile-time error). The bond is not mutable.
    
    const Map<int, int> d = {}; // the bond between "d" and the (anonymous) object {} is immutable. And the bound object is immutable.
    d[10] = 100;                // **this is WRONG** (runtime exception). The bound object is immutable.

And you can "mix" things:

    Map<int, int> e = const {}; // the bond between "e" and the (anonymous) object {} is mutable. However, the bound object is immutable.
    e = {1: 10};                // this is OK.

    class Metadata {
      static const TAG = 'matadata'; // const properties must be static (class properties).
      final String _onError;
      Metadata(String this._onError);
      const Metadata.forever(String this._onError);
      String toString() => _onError;
    }

    // "f" is created at runtime. The bond is immutable and the bound object is immutable.
    // This is "looks like" a "const" variable... but initialised at runtime.
    final Metadata f = Metadata.forever('exitOnError-' + Random.secure().nextInt(100).toString());

> As you can see, both levels imply immutable bonds. However, in one case the bound object is (unless otherwise stated)
> mutable (`final`) while in the other (`const`) it is not.

One important point to keep in mind is that immutable bonds are created during the variables **instantiations**.
This is important to keep in mind, in order to understand what happens with classes.

# const: compile-time constants 

## General description

In Dart the keyword `const` defines an _immutable bond_ to an _immutable object_ that is initialised at compile time.

The code below illustrates this idea:

Let's define a _compile-time immutable (non-primitive type)_ object: 

    const Map<String, int> m1 = { 'a': 1, 'b': 2 };

> Please note that you can also write: `const Map<String, int> m1 = const { 'a': 1, 'b': 2 };`

Let's try to modify the (anonymous) object referenced by `m1`:

    try { m1['d'] = 3; } catch (e) { print("You cannot do that! ${e}"); }
    // => You cannot do that! Unsupported operation: Cannot set value in unmodifiable Map 

Let's try break the bond between `m1` and `{ 'a': 1, 'b': 2 }`:

    m1 = {}; // => Compile-time error !!!

You cannot do that. The script does not even start. The error is a compile-time error.

> This test is interesting since, in this example, the type of `m1` is a [non-primitive](https://github.com/denis-beurive/dart-playground/blob/master/notes/types.md)
> one. This means that `m1` stores the _reference_ to the anonymous object `{ 'a': 1, 'b': 2 }`.
> You may think that only the reference is immutable, not the _content_ of the referenced object.
> In other words, you may think that you cannot assign another object to `m1`, but you could modify
> the referenced (anonymous) object: that's wrong. You cannot assign a new object to `m1` and you
> cannot modify the referenced object. The bond, and the object, are both immutable. 

Please note that the notation below is valid:

    ((Map<String, int> m) {
        print("This immutable anonymous parameter is: " + m.toString());
    })(const { 'a': 1, 'b': 2});
    // => This immutable anonymous parameter is: {a: 1, b: 2}

Of course, the code below is not valid:

    try {
        ((Map<String, int> m) { m['a'] = 1; })(const {});
    } catch (e) { print("You cannot do that! ${e}"); }
    // => You cannot do that! Unsupported operation: Cannot set value in unmodifiable Map

## const in class

The keyword "`const`" can be used within a class. However it can be applied to static properties (also called class
properties) only. This restriction makes sense since there would be no reason to define an instance property which
value cannot change from an instance to the other.

Ever hear of Occam's razor? "_Pluralitas non est ponenda sine necessitate_"

## Const constructors



# final: runtime constants

## General description

In Dart the keyword `final` defines an **immutable bond** to a (unless otherwise stated) **mutable object** that is initialised at runtime.

The bond is initialised at runtime:

    final int randomValue = Random.secure().nextInt(100);
    print("The value of the runtime immutable variable <randomValue> is ${randomValue}. It will change from execution to execution.");
    final int newRandomValue; // Implicitly initialised to the value 0.
    
The bond is not mutable:

    final Map<String, int> map = { 'a': 1 };
    map = {}; // This code is not valid. The bond is not mutable.

However, the bound object is mutable:

    final Map<String, int> map = { 'a': 1 };
    map['a'] = 2; // OK
    map['b'] = 3; // OK
    print("map = ${map}"); // => map = {a: 2, b: 3}

> Please note that you can create a bound object that is not mutable:
>
>     final Map<String, int> map2 = const { 'a': 1 };
>     try {
>         map2['a'] = 2; // KO => The bound object is NOT mutable.
>     } catch (e) { print("You cannot do that! ${e}"); }
>     // You cannot do that! Unsupported operation: Cannot set value in unmodifiable Map

## final in class

The use case of a class is interesting. Within a class definition, a final property _may not appear to be initialised_.
For example:

    class Log{
      final String _path;
      Log(this._path);
    }

You may think that the property "`_path`" references an empty string (the default value for an instance of String).
Thus, you may think that the immutable bond (between the property and the anonymous object "") is already created.
So, you may think: "if I call the constructor, an error will be raised".

In fact, until the class gets instantiated, the property is not instantiated (thus the bond is not created yet).
The bond will be created during the class instantiation - thus, during the constructor execution.







