import 'package:colorize/colorize.dart';

enum LogLevel{debug, info, warning, error, fatal}

class Level {
  final int criticality;
  final String name;
  const Level(this.criticality, this.name);
}

class LogMessage {

  Map<LogLevel, Level> _levels = {
    LogLevel.fatal: Level(0, 'FATAL'),
    LogLevel.error: Level(1, 'ERROR'),
    LogLevel.warning: Level(2, 'WARNING'),
    LogLevel.info: Level(3, 'INFO'),
    LogLevel.debug: Level(4, 'DEBUG')
  };

  DateTime _timestamp;
  Level _level;
  bool _serialized;
  String _message;

  set timestamp(String dateAndTime) => _timestamp = DateTime.parse(dateAndTime);

  set level(LogLevel level) => _level = _levels[level];

  set message(String message) {
    RegExp exp = new RegExp(r'\r?\n');
    if (exp.hasMatch(message)) {
      _message = Uri.encodeFull(message);
      _serialized = true;
    } else {
      _message = message;
      _serialized = false;
    }
  }

  String get message => _serialized ? Uri.decodeFull(_message) : _message;
  String get timestamp => _timestamp.toIso8601String();
  int get criticality  => _level.criticality;
  String get levelName => _level.name;

  String toString() => "${Colorize(_timestamp.toIso8601String())..lightCyan()} ${Colorize(_level.name)..lightGreen()} ${Colorize(_serialized ? 'S' : 'R')..lightYellow()} ${_message}";
}

main() {
  LogMessage m = LogMessage();
  m.timestamp = '2012-02-27 13:27:00';
  m.level = LogLevel.debug;
  m.message = "This is a typical DEBU message\nwith mote that one line of text";

  print(m);
  print("message: ${Colorize(m.message)..lightYellow()}");
  print("timestamp: ${m.timestamp}");
  print("level criticality: ${m.criticality}");
  print("level name: ${m.levelName}");
}