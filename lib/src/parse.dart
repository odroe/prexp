import 'constants.dart';
import 'lex_token.dart';
import 'lex_type.dart';
import 'lexer.dart';
import 'token.dart';
import 'utils.dart';

/// Parses a string of Dart code and returns the AST.
List<Token> parse(
  String input, {
  String delimiter = defautlDelimiter,
  String prefixes = defaultPrefixes,
}) {
  final List<LexToken> lexicalTokens = lexer(input);
  final String defaultPattern = '[^${escapeRegExp(delimiter)}]+?';
  final List<Token> tokens = <Token>[];

  int key = 0;
  int index = 0;
  String path = '';

  String? tryConsume(LexType type) {
    if (index < lexicalTokens.length && type == lexicalTokens[index].type) {
      return lexicalTokens[index++].value;
    }
    return null;
  }

  String mustConsume(LexType type) {
    final String? value = tryConsume(type);
    if (value != null) {
      return value;
    }

    final token = lexicalTokens[index];
    throw FormatException(
      'Unexpected ${token.type} at ${token.index}, expected $type',
      input,
      token.index,
    );
  }

  String consumeText() {
    String result = '';
    String? value;
    while ((value = (tryConsume(LexType.char) ?? tryConsume(LexType.escape))) !=
        null) {
      result += value!;
    }

    return result;
  }

  while (index < lexicalTokens.length) {
    final String? char = tryConsume(LexType.char);
    final String? name = tryConsume(LexType.name);
    final String? pattern = tryConsume(LexType.pattern);

    if (name?.isNotEmpty ?? pattern?.isNotEmpty ?? false) {
      String prefix = char ?? '';

      if (!prefixes.contains(prefix)) {
        path += prefix;
        prefix = '';
      }

      if (path.isNotEmpty) {
        tokens.add(StringToken(path));
        path = '';
      }

      tokens.add(MetadataToken(
        name: name ?? (key++).toString(),
        prefix: prefix,
        suffix: '',
        pattern: pattern ?? defaultPattern,
        modifier: tryConsume(LexType.modifier) ?? '',
      ));
      continue;
    }

    final String? value = char ?? tryConsume(LexType.escape);
    if (value != null) {
      path += value;
      continue;
    }

    if (path.isNotEmpty) {
      tokens.add(StringToken(path));
      path = '';
    }

    final String? open = tryConsume(LexType.open);
    if (open != null) {
      final prefix = consumeText();
      final name = tryConsume(LexType.name) ?? '';
      final pattern = tryConsume(LexType.pattern) ?? '';
      final suffix = consumeText();

      mustConsume(LexType.close);

      tokens.add(MetadataToken(
        name: name.isEmpty
            ? pattern.isNotEmpty
                ? (key++).toString()
                : ''
            : name,
        prefix: prefix,
        suffix: suffix,
        pattern: name.isNotEmpty && pattern.isEmpty ? defaultPattern : pattern,
        modifier: tryConsume(LexType.modifier) ?? '',
      ));
      continue;
    }

    mustConsume(LexType.end);
  }

  return tokens;
}
