// This script illustrates the use of regular expressions.
//
// The pattern syntax is identical to the general syntax used by other scripting
// languages. However, be aware that the character "/" is not a special character.

import 'package:colorize/colorize.dart';

main() {

  (() {
    String r = r'(^a.)';
    String s = 'abc';
    print(Colorize('----------------------')..lightGreen());
    RegExp exp = new RegExp(r);
    print("Does '${s}' matches '${r}': ${exp.hasMatch(s).toString()}");
    Iterable<Match> matches = exp.allMatches(s);
    print("Number of matches: ${matches.length}");

    if (matches.length > 0) {
      print("The string matches the regular expression.");
      int n=0;
      matches.forEach((Match m) {
        print("  [match ${n++}] : number of captured groups: ${m.groupCount}");

        for (int g=0; g<=m.groupCount; g++) {
          print("    [${g}] -> ${m.group(g)}");
        }
      });
    }
  })();

  (() {
    String r = r'(a.)';
    String s = 'abcdazerty aa';
    print(Colorize('----------------------')..lightGreen());
    RegExp exp = new RegExp(r);
    print("Does '${s}' matches '${r}': ${exp.hasMatch(s).toString()}");
    Iterable<Match> matches = exp.allMatches(s);
    print("Number of matches: ${matches.length}");

    if (matches.length > 0) {
      print("The string matches the regular expression.");
      int n = 0;
      matches.forEach((Match m) {
        print("  [match ${n++}] : number of captured groups: ${m.groupCount}");
        for (int g = 0; g <= m.groupCount; g++) {
          print("    [${g}] -> ${m.group(g)}");
        }
      });
    }
  })();

  (() {
    String r = r'(a.)(x..)(z\d)';
    String s = 'a1x00z9cvbfa2x33z8a3';
    print(Colorize('----------------------')..lightGreen());
    RegExp exp = new RegExp(r);
    print("Does '${s}' matches '${r}': ${exp.hasMatch(s).toString()}");
    Iterable<Match> matches = exp.allMatches(s);
    print("Number of matches: ${matches.length}");

    if (matches.length > 0) {
      int n = 0;
      matches.forEach((Match m) {
        print("The string matches the regular expression.");
        print("  [match ${n++}] : number of captured groups: ${m.groupCount}");
        for (int g = 0; g <= m.groupCount; g++) {
          print("    [${g}] ${m
              .group(g)
              .length} -> ${m.group(g)}");
        }
      });
    }
  })();

  (() {
    print(Colorize('----------------------')..lightGreen());
    String r = r'(^(/[\w]+)+/web($|/))';
    RegExp exp = new RegExp(r);

    List<String> urls = [
      '/p/web/',
      '/path/web',
      '/path/web/a',
      '/path/web/a/',
      '/path/web/a/c'
    ];

    urls.forEach((String url) {
      print("Does '${url}' matches '${r}': ${exp.hasMatch(url).toString()}");
      if (exp.hasMatch(url)) {
        Iterable<Match> matches = exp.allMatches(url);
        int n = 0;
        matches.forEach((Match m) {
          print("The string matches the regular expression.");
          print("  [match ${n++}] : number of captured groups: ${m.groupCount}");
          for (int g = 0; g <= m.groupCount; g++) {
            print("    [${g}] ${m
                .group(g)
                .length} -> ${m.group(g)}");
          }
        });
      }
    });


  })();




}