// Resources:
// https://stackoverflow.com/questions/26826521/executing-bundle-of-functions-by-their-metadata-tag-in-dart-lang
// https://stackoverflow.com/questions/53415552/dart-how-to-get-metadata-for-anything-other-than-classes-and-class-members
// https://www.dartlang.org/articles/dart-vm/reflection-with-mirrors

import 'dart:mirrors';
import 'package:colorize/colorize.dart';

/// This class represents the metadata "OnFailure".
class OnFailure {
  final int criticalityLevel;
  final String handlerName;
  /// Constructor.
  /// [criticalityLevel] represent the level of criticality.
  /// [handlerName] represents the name of the function to execute.
  const OnFailure(int this.criticalityLevel, String this.handlerName);
}

/// This class represents the metadata "Log".
class Log {
  final String destination;
  const Log(String this.destination);
}

/// This class represents the metadata "Doc".
class Doc {
  final String path;
  const Doc(String this.path);
}

@OnFailure(0, 'onFatalHandler')
class ClassProcessor {
  @Doc('/var/doc/ClassProcessor')
  bool status;

  @Log('/var/log/ClassProcessor')
  bool call(int value) {
    return value > 0;
  }
}

@OnFailure(0, 'onFatalHandler')
typedef bool TypeProcessorBool(int value);

@Doc('/var/doc/data')
int data = 10;

main() {

  ClassProcessor processorClass = ClassProcessor();

  // Get the metadata for a class.
  print(Colorize("Classes")..bgGreen());
  InstanceMirror instanceMirror = reflect(processorClass);
  ClassMirror classMirror = instanceMirror.type;
  print(instanceMirror.type.metadata); // => [InstanceMirror on Instance of 'OnFailure']
  OnFailure metadata = classMirror.metadata[0].reflectee;
  print("Critical level: ${metadata.criticalityLevel}"); // => Critical level: 0
  print("Handler name: ${metadata.handlerName}"); // => Handler name: onFatalHandler

  // Get the metadata for a method.
  print(Colorize("Class methods")..bgGreen());
  MethodMirror methodMirror = classMirror.declarations[Symbol('call')];
  Log log = methodMirror.metadata[0].reflectee;
  print("Log file is ${log.destination}");

  // Get the metadata for a property.
  print(Colorize("Class properties")..bgGreen());
  VariableMirror variableMirror = classMirror.declarations[Symbol('status')];
  Doc doc = variableMirror.metadata[0].reflectee;
  print("Doc file is ${doc.path}");

  // Get the metadata for a typedef.
  // ???
  print(Colorize("Typedef")..bgGreen());
  TypeProcessorBool processorInstance = (int value) {
    if (value > 0) { print("That's OK."); }
    else { print("A fatal error occurred !"); }
  };
  instanceMirror = reflect(processorInstance);
  int n=0;
  instanceMirror.type.declarations.forEach((Symbol symbol, DeclarationMirror declarationMirror) {
    if (declarationMirror.metadata.length > 0) {
      n++;
      declarationMirror.metadata.forEach((var value) => print("${n}: ${value.reflectee}"));
    }
  });

  // Get the metadata for a variable.
  // ???
  print(Colorize("Global variable")..bgGreen());
  instanceMirror = reflect(data);
  print("instanceMirror.reflectee => ${instanceMirror.reflectee}"); // => 10
  n=0;
  instanceMirror.type.declarations.forEach((Symbol symbol, DeclarationMirror declarationMirror) {
    if (declarationMirror.metadata.length > 0) {
      n++;
      declarationMirror.metadata.forEach((var value) => print("${n}: ${value.reflectee}"));
    }
  });
}

