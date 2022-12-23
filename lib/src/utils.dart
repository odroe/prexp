/// Escape a regular expression string.
String escapeRegExp(String input) {
  return input.replaceAllMapped(
      RegExp(r'([.+*?=^!:${}()[\]|/\\])'), (match) => '\\${match[1]}');
}
