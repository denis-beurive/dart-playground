// The script illustrates the manipulations on files.
// If you use programming languages such as PHP, Perl or Python, be aware that
// many operations on files execute asynchronously.

import 'dart:io';
import 'dart:async';
import 'dart:convert';

main() async {

  File file = File('test.txt');

  // Write 5 lines to the file.
  //
  // Please note that write operations are buffered. You can't be sure that the
  // data has effectively been written to the file before the later is closed.
  IOSink fs = file.openWrite();
  for (int i=1; i<6; i++) {
    fs.write('Line ' + i.toString() + "\n");
  }

  // Warning !
  //
  // The method "File.close()" executes asynchronously ! Thus, if you do not wait
  // for the call to terminate, then you will continue the script's execution
  // while all the data is not written to the file yet.
  await fs.close();

  // ---------------------------------------------------------------------------
  // TEST 1: read a file using "listen".
  // ---------------------------------------------------------------------------

  // Please note that we create a stream. Right now, the stream is "just" created.
  // It does not start generating events.
  Stream<List<int>> file_stream =  file.openRead();

  // Read the content of the file. We apply a listener to the stream. Then, it
  // starts to generate events.
  // Note: on my system, the maximum size for a chuck of data is 65536 bytes.
  //       However, this size depends on the system the script is executed on.
  file_stream.listen((List<int> data) {
    String content = utf8.decode(data);
    print("One chuck of data has been read. It contains a sequence of ${data.length} bytes. Decoded from UTF8:\n${content}");
  }).onDone(() => print('Done with [listen()]'));

  // ---------------------------------------------------------------------------
  // TEST 2: read a file using "await for".
  // ---------------------------------------------------------------------------

  // Remember: a single subscription stream can not be used twice.
  file_stream =  file.openRead();

  await for (List<int> data in file_stream) {
    String content = utf8.decode(data);
    print("One chuck of data has been read. It contains a sequence of ${data.length} bytes. Decoded from UTF8:\n${content}");
  }
  print("Done with [await for]");

  // ---------------------------------------------------------------------------
  // TEST 3: read a file using the recommended ways.
  // ---------------------------------------------------------------------------

  String content = file.readAsStringSync();
  print("[SYNC] The content of the file is:\n${content}");

  await file.readAsString().then((content) {
    print("[ASYNC] The content of the file is:\n${content}");
  });

  // The code below executes asynchronously.

  file.openRead()
      .transform(utf8.decoder)       // Decode bytes to UTF-8.
      .transform(new LineSplitter()) // Convert stream to individual lines.
      .listen((String line) {        // Process results.
        print('$line: ${line.length} bytes');
      }, // Please note that "listen" returns an instance of StreamSubscription.
      onDone: () { print('File is now closed.'); },
      onError: (e) { print(e.toString()); });
}