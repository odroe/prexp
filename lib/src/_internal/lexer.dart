//// Lexical Type.
enum LexType {
  open,
  close,
  pattern,
  name,
  char,
  escape,
  modifier,
  end,
}

/// Lexical Token.
class LexToken {
  /// Lexical type.
  final LexType type;

  /// Lexical value.
  final String value;

  /// Lexical value index.
  final int index;

  /// Lexical token constructor.
  const LexToken(this.type, this.index, this.value);

  @override
  String toString() => 'LexToken($type, $index, $value)';
}

/// Lexical extractor.
List<LexToken> lexer(String input) {
  final List<LexToken> tokens = <LexToken>[];
  for (int index = 0; index < input.length;) {
    final String char = input[index];

    // Modifier
    if ([r'*', r'+', r'?'].contains(char)) {
      tokens.add(LexToken(LexType.modifier, index, input[index++]));
      continue;

      // Escape
    } else if (char == r'\') {
      tokens.add(LexToken(LexType.escape, index++, input[index++]));
      continue;

      // Open
    } else if (char == r'{') {
      tokens.add(LexToken(LexType.open, index, input[index++]));
      continue;

      // Close
    } else if (char == r'}') {
      tokens.add(LexToken(LexType.close, index, input[index++]));
      continue;
    }

    // Name
    if (char == r':') {
      String name = '';
      int j = index + 1;

      while (j < input.length) {
        final int code = input.codeUnitAt(j);

        if (
            // _
            code == 95 ||
                // a-z
                (code >= 97 && code <= 122) ||
                // A-Z
                (code >= 65 && code <= 90) ||
                // 0-9
                (code >= 48 && code <= 57)) {
          name += input[j++];
          continue;
        }

        break;
      }

      if (name.isEmpty) {
        throw FormatException('Missing parameter name at $index');
      }

      tokens.add(LexToken(LexType.name, index, name));
      index = j;
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
      continue;
    }

    // Char
    tokens.add(LexToken(LexType.char, index, input[index++]));
  }

  return tokens..add(LexToken(LexType.end, input.length, ''));
}
