import 'lex_token.dart';
import 'lex_type.dart';

/// Lexical extractor.
List<LexToken> lexer(String input) {
  final List<LexToken> tokens = <LexToken>[];
  for (int index = 0; index < input.length;) {
    final String char = input[index];

    // Modifier
    if ([r'*', r'+', r'?'].contains(char)) {
      tokens.add(LexToken(LexType.modifier, index, char));
      index++;
      continue;

      // Escape
    } else if (char == r'\') {
      tokens.add(LexToken(LexType.escape, index++, input[index++]));
      continue;

      // Open
    } else if (char == r'{') {
      tokens.add(LexToken(LexType.open, index, char));
      index++;
      continue;

      // Close
    } else if (char == r'}') {
      tokens.add(LexToken(LexType.close, index, char));
      index++;
      continue;
    }

    // Name
    if (char == r':') {
      String name = '';
      index++;

      while (index < input.length) {
        final String char = input[index];
        final int code = input.codeUnitAt(index);

        if (
            // _
            code == 95 ||
                // a-z
                (code >= 97 && code <= 122) ||
                // A-Z
                (code >= 65 && code <= 90) ||
                // 0-9
                (code >= 48 && code <= 57)) {
          name += char;
          index++;
          continue;
        }

        break;
      }

      if (name.isEmpty) {
        throw FormatException('Missing parameter name at $index');
      }

      tokens.add(LexToken(LexType.name, index, name));
      continue;
    }

    if (char == r'(') {
      int count = 1;
      String pattern = '';
      index++;

      if (input[index] == r'?') {
        throw FormatException('Pattern cannot start with "?" at $index');
      }

      while (index < input.length) {
        if (input[index] == r'\') {
          pattern += input[index++] + input[index++];
          continue;
        }

        if (input[index] == r')') {
          count--;
          if (count == 0) {
            index++;
            break;
          }
        } else if (input[index] == '(') {
          count++;
          if (input[index + 1] != '?') {
            throw FormatException('Pattern cannot start with "(" at $index');
          }
        }

        pattern += input[index++];
      }

      if (count > 0) {
        throw FormatException('Missing ")" at $index');
      }
      if (pattern.isEmpty) {
        throw FormatException('Missing pattern at $index');
      }

      tokens.add(LexToken(LexType.pattern, index, pattern));
    }

    // Char
    tokens.add(LexToken(LexType.char, index++, char));
  }

  return tokens..add(LexToken(LexType.end, input.length, ''));
}
