// This script illustrates the use of channels.
//
// Resources:
// https://github.com/dart-lang/sdk/issues/26738

import 'dart:isolate';
import 'dart:async';
import 'dart:math';
import 'package:colorize/colorize.dart';

/// This class represents a message provided to the isolate.
class Message {
  String login;
  String password;
  String host;
  String command;
  bool status=null;
  bool last=false;

  Message(String this.host, String this.login, String this.password, String this.command, {bool this.status});

  String toString() {
    if (null == status) {
      return "Command to execute: (command=\"${command}\", host=\"${host}\", login=\"${login}\", password=\"${password}\")";
    }
    return "The command \"${command}\" on the host \"${host}\", authentified as (${login}/${password}), has been executed. Status: ${status ? 'true' : 'false'}. Is it the last command ? ${last ? 'yes' : 'no'}.";
  }

  Message setStatus(bool status) { this.status = status; return this; }
  Message setLast([bool end=true]) { this.last=end; return this; }
  bool isLast() { return last; }
}

/// This function is the entry point for an isolate that fires and forgets a command
/// on a remote host.
/// [message] represents the parameters required to execute the command.
void executeRemoteCommandFireAndForget(Message message) {
  print(Colorize("Fire and forget: ${message}")..lightRed());
}

/// This function is the entry point for an isolate that waits for a command to
/// be executed. When the command has been executed, the isolate returns the status
/// of the operation.
/// [writtenToByIsolate] represents the port that the current isolate should use to send
///            messages to its interlocutor.
void executeRemoteCommandInteractWith(SendPort writtenToByIsolate) async {
  print(Colorize("Interacter: start")..lightGreen());
  Random rg = Random.secure();

  // "sendPort" can only be used to send messages. However, the current isolate
  // needs a way to get messages from the outside world. To do that, it instantiates
  // a receiver port and sends the sender port associated to the newly instantiated
  // port to its interlocutor ("Main", as it happens). Thus, both interlocutors
  // get a port they can use to send messages.
  ReceivePort listenedToByIsolate = ReceivePort(); // Used by the current isolate.
  SendPort writtenToByMain = listenedToByIsolate.sendPort; // Used by "Main".
  print(Colorize("Interacter: inform Main about the port it should use to send messages to me.")..lightGreen());
  writtenToByIsolate.send(writtenToByMain);

  Stream<dynamic> inputStream = listenedToByIsolate.asBroadcastStream();
  int counter = 0;
  print(Colorize("Interacter: wait for commands to execute.")..lightGreen());
  // Note: the "await for" is a loop !
  await for (Message receivedMessage in inputStream) {
    print(Colorize("Interacter: got a message from Main: ${receivedMessage}.")..lightGreen());
    bool last = counter++ > 2;
    writtenToByIsolate.send(receivedMessage.setStatus(rg.nextBool()).setLast(last));
    if (last) { break; }
  }
  listenedToByIsolate.close();  // WARNING! If you don't close the channel, the script won't terminate.
  print(Colorize('Interacter: leave the interacter')..lightGreen());
}

main() async {

  // Create an isolate which accepts as the only parameter an instance of the
  // class Message. Please note that this isolate cannot exchange data with the
  // "outside world".

  Isolate.spawn(
      executeRemoteCommandFireAndForget,
      Message('localhost', 'admin', 'password', 'ls')
  );

  // Create a *unidirectional* channel that will be used to send data from "the isolate"
  // to "Main". The channel has a "sender port" and a "receiver port".
  //
  // <Main> (receiver port) <<----[channel MI]---- (sender port) <the isolate>
  //
  // * "Main" listens to the channel.
  // * "The isolate" writes to the channel.

  ReceivePort listenedToByMain = ReceivePort(); // Used by "Main".
  SendPort writtenToByIsolate = listenedToByMain.sendPort; // Used to the isolate.
  Isolate.spawn(executeRemoteCommandInteractWith, writtenToByIsolate);

  // The isolate creates a channel that will be used to send data from "Main" to
  // "the isolate".
  //
  // <Main> (sender port) ----[channel IM]---->> (receiver port) <the isolate)
  //
  // * "Main" sends to the channel.
  // * 'The isolate" listens to the channel.

  Stream<dynamic> incomingMessagesStream = listenedToByMain.asBroadcastStream();
  SendPort writtenToByMain = await incomingMessagesStream.first;
  print("Main: got the port that I should use to send messages to the interacter.");

  // Now, we can exchange data in both directions:
  //
  // <Main> (sender port)    ----[channel IM]---->> (receiver port) <the isolate)
  // <Main> (receiver port) <<----[channel MI]----  (sender port) <the isolate>

  // Send the first command to execute on a remote host.
  print("Main: send a message to the interacter.");
  writtenToByMain.send(Message('localhost', 'admin', 'password', 'ls'));

  // Wait for the command to be executed.
  print("Main: wait for responses from the interacter.");
  // Note: the "await for" is a loop !
  await for (Message message in incomingMessagesStream) {
    print("Main: ${message}");
    if (message.isLast()) {
      print("Main: this was the last command!");
      break;
    } else {
      print("Main: send a message to the interacter.");
      writtenToByMain.send(Message('localhost', 'admin', 'password', 'ls'));
    }
  }

  listenedToByMain.close(); // WARNING! If you don't close the channel, the script won't terminate.
  print('Main: terminate the script');
}