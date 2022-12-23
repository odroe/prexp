import 'constants.dart';
import 'default_encode.dart';
import 'token.dart';
import 'types.dart';

typedef PathFunction<T extends Params> = String Function([T? data]);

/// Expose a method for transforming tokens into the path function.
PathFunction<Params> tokensToFunction(
  Iterable<Token> tokens, {
  bool sensitive = defatulSensitive,
  MetadataParser encode = defaultMetadataParser,
  bool validate = defaultValidate,
}) {
  final Iterable<RegExp?> matches = tokens.map((token) {
    if (token is MetadataToken) {
      return RegExp(token.pattern, caseSensitive: sensitive);
    }
  });

  return ([Params? data]) {
    String path = '';

    for (int index = 0; index < tokens.length; index++) {
      Token token = tokens.elementAt(index);

      if (token is StringToken) {
        path += token.value;
        continue;
      }

      token = token as MetadataToken;

      final dynamic value = data?[token.name];
      final bool optional = token.modifier == '?' || token.modifier == '*';
      final bool repeat = token.modifier == '*' || token.modifier == '+';

      if (value is Iterable) {
        if (!repeat) {
          throw FormatException(
            'Expected "$value" to not repeat, but got token with repeat '
            'modifier "${token.modifier}"',
          );
        }

        if (value.isEmpty) {
          if (optional) {
            continue;
          }

          throw FormatException(
            'Expected "$value" to not be empty',
          );
        }

        for (final dynamic rawSegment in value) {
          final String segment = encode(rawSegment.toString(), token);

          if (validate && !(matches.elementAt(index)!.hasMatch(segment))) {
            throw FormatException(
              'Expected all "$value" to match "${token.pattern}"',
            );
          }

          path += token.prefix + segment + token.suffix;
        }

        continue;
      }

      if (value is String || value is num) {
        final String segment = encode(value.toString(), token);

        if (validate && !(matches.elementAt(index)!.hasMatch(segment))) {
          throw FormatException(
            'Expected "$value" to match "${token.pattern}"',
          );
        }

        path += token.prefix + segment + token.suffix;
        continue;
      }

      if (optional) {
        continue;
      }

      final typeOfMessage = repeat ? 'an iterable' : 'a string';
      throw FormatException(
        'Expected "$value" to be $typeOfMessage',
      );
    }

    return path;
  };
}
