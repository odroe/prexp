import '../token.dart';

/// Escape a regular expression string.
String escapeRegExp(String input) {
  return input.replaceAllMapped(RegExp(r'([.+*?=^!:${}()[\]|/\\])'), (match) {
    return '\\${match[1]}';
  });
}

String segmentParser(String value, MetadataPrexpToken token) => value;
