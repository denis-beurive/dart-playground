# Types in Dart

## Primitive and non-primitive types

In Dart, every variable is an object. The class which defines the instantiated object is called the "type" of the variable.

However, some classes have constructors, others don't.
For example:

* The class "String" does not have a constructor.
* The class "Map" has a constructor.

Classes that don't have a constructor represents primitive types (ex: String, int...).

Classes that have a constructor represents non-primitive types (ex: Map, Stream...).

## Values and references

Primitive types are manipulated by value.

    String s1 = 'First string';
    String s2 = s1;
    s2 = s2.toUpperCase();
    assert(s1 != s2 && 'Frist string' == s1); // This assertion is true.

Non-primitive types are manipulated by reference.

    Map<String, int> m1 = {
      'a': 1,
      'b': 2
    };
    Map<String, int> m2 = m1;
    m2['c'] = 3;
    assert(m1.containsKey('c') && 3 == m1['c']); // This assertion is true.
    
    ((Map<String, int> m) {
      m['d'] = 4;
    })(m1);
    assert(m1.containsKey('d') && 4 == m1['d']); // This assertion is true.



