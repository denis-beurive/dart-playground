# Immutability const / final

## Overview

From [Wikipedia](https://en.wikipedia.org/wiki/Immutable_object):

_In object-oriented and functional programming, an immutable object (unchangeable object)
is an object whose state cannot be modified after it is created. This is in contrast
to a mutable object (changeable object), which can be modified after it is created._

Dart defines two keywords that deal with immutability: `const` and `final`.

Generally speaking:

* The keyword "`const`" (always) creates an **immutable object** that is initialised at **compile-time**.
* The keyword "`final`" (always) creates an **immutable bond at runtime**.

Now, things get a little more complex, depending on the context. See below.

## "const" in details

### The theory

The keyword "`const`" (always) creates an **immutable object** that is initialised at **compile-time**, and, _depending on
the context_ (see below), it creates an **immutable bond** or not.

The expression `const <type> <variable name> = [const] <object>` creates an **immutable object** and an **immutable bond**.
Examples (the two lines are equivalent):

    const Map<String, int> v1 = { 'a': 1, 'b': 2 };
    const Map<String, int> v1 = const { 'a': 1, 'b': 2 };

The expression `const <object>` only creates an **immutable object**.
Example:

    Map<String, int> v1 = const { 'a': 1, 'b': 2 }; // The bond is not immutable.
    ((Map<String, int> v) { print(v); })(const { 'a': 1, 'b': 2 });

When used within a class:

* in a property declaration, the keyword "`const`" can be applied to static properties
  (also called class properties) only. This restriction makes sense since there would be no reason to define an instance
  property which value cannot change from an instance to the other. Ever hear of Occam's razor?
  "_Pluralitas non est ponenda sine necessitate_".
* The keyword "`const`" may be used to qualify a constructor. See below.

A "const constructor" always returns an immutable object. However, depending on how it is used, the returned object
is initialised at compile-time or at runtime:

* within a "_const construction_": the constructor parameter must be a constant expression. In this case, the instantiated object is instantiated at compile-time.
  *  `const <type> <variable name> = [const] ConstConstructor(...)`
  *  `const ConstConstructor(...)`
* within a "_non-const construction_": the constructor parameter does not have to be a constant expression. In this case, the instantiated object is instantiated at runtime.
  *  `<type> <variable name> = ConstConstructor(...)`
  *  `ConstConstructor(...)`

> Please note that built-in types (like Map or String) does not have an explicit "const constructor". "const" objects are
> built from literal expressions.

### Examples

Let's create an **immutable object** and an **immutable bond**.

    const Map<String, int> v1 = { 'a': 1, 'b': 2 };
    // or
    const Map<String, int> v1 = const { 'a': 1, 'b': 2 };

* You cannot mutate the object bound to `v1` - `{ 'a': 1, 'b': 2 }` (immutable object).
* The (anonymous) object (`{ 'a': 1, 'b': 2 }`) is instantiated at compile-time.
* You cannot assign another object to `v1` (immutable bond). Ex: `v1 = {};` is forbidden.

Let's create an **immutable object**, only.

    Map<String, int> v1 = const { 'a': 1, 'b': 2 };
    // or
    ((Map<String, int> v1) { print(v1); })(const { 'a': 1, 'b': 2 });

* You cannot mutate the object bound to `v1` - `{ 'a': 1, 'b': 2 }` (immutable object).
* The (anonymous) object (`{ 'a': 1, 'b': 2 }`) is instantiated at compile-time.    
* You can assign another object to `v1` (mutable bond). Ex: `v1 = {};` is allowed.

Let's create a "const constructor".

    class Metadata {
      static const TAG = 'matadata'; // const properties must be static (class properties).
      final String _onError;
      Metadata(String this._onError);
      const Metadata.forever(String this._onError);
      String toString() => _onError;
    }

    const Metadata meta1 = Metadata.forever('logoutAndClose');
    Metadata meta2 = const Metadata.forever('logoutAndClose');
    const Metadata meta3 = Metadata.forever('logoutAndClose');
    Metadata meta4 = Metadata.forever('logoutAndClose' + Random.secure().nextInt(100).toString());
    
* **`meta1`**: the bond is immutable. The bound object is immutable and instantiated at compile-time.
* **`meta2`**: the bond is mutable. The bound object is immutable and instantiated at compile-time..
* **`meta3`**: `meta1` and `meta3` reference the same object (same instance).
* **`meta4`**:  the bond is mutable. The bound object is immutable and instantiated at runtime.

## "final" in details

### The theory

The keyword "`final`" (always) creates an **immutable bond at runtime** to a (_unless otherwise stated_) **mutable object** that
is (_unless otherwise stated_) initialised **at runtime**.

The expression `final <type> <variable name> = <object>` creates an **immutable bond at runtime** to a **mutable object** which is
instantiated **at runtime**. Example:

    final Map<String, int> v1 = { 'a': 1, 'b': 2 };

The expression `final <type> <variable name> = const <object>` creates an **immutable bond at runtime** to a **immutable object** which is
instantiated **at compile-time**. Example:

    final Map<String, int> v1 = const { 'a': 1, 'b': 2 };
    
When used within a class:

"final" properties are used when implementing classes that have a "const constructor". That is: they are used when the
class needs to be instantiated at compile-time (to create metadata, for example), or when immutable instances needs to
be created.
    
### Examples

Let's create an **immutable bond at runtime** to a mutable object (instantiated at runtime).

    final Map<String, int> map = { 'a': 1 };
    
* You cannot assign another object to `map` (immutable bond). Ex: `map = {};` is forbidden.
* You can mutate the (anonymous) object bound to `map` - `{ 'a': 1 }` (mutable object).
* The (anonymous) object (`{ 'a': 1 }`) is instantiated a runtime.

Let's create an **immutable bond at runtime** to an immutable object (instantiated at compile-time).

    final Map<String, int> map = const { 'a': 1 };
    
* You cannot assign another object to `map` (immutable bond). Ex: `map = {};` is forbidden.
* You can mutate the (anonymous) object bound to `map` - `{ 'a': 1 }` (immutable object).
* The (anonymous) object (`{ 'a': 1 }`) is instantiated a compile-time.

Let's create a final property.

The use case of a class is interesting. Within a class definition, a final property _may not appear to be initialised_.
For example:

    class Log{
      final String _path; // Not yet instantiated.
      bool debug; // This class has no "const constructor". A non-final property is OK.
      Log(this._path); // Calling the constructor will instantiate the property.
    }

You may think that the property "`_path`" references an empty string (the default value for an instance of String).
Thus, you may think that the immutable bond (between the property and the anonymous object "") is already created.
So, you may think: "_if I call the constructor, an error will be raised !_".

In fact, until the class gets instantiated, the property is not instantiated (thus the bond is not created yet).
The bond will be created during the class instantiation - thus, during the constructor execution.

Now, let's create a "const" constructor.

    class Log{
      final String _path;
      Log(this._path);
      const Log.forever(this._path);
    }

Since a "const constructor" creates an immutable object, all its properties must be "final" : once instantiated and
initialised, the property value cannot change (in other words, the object cannot mutate).

## Examples

[const vs final](https://github.com/denis-beurive/dart-playground/blob/master/bin/const-vs-final.dart)

