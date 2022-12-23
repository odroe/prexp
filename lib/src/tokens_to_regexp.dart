import 'constants.dart';
import 'default_encode.dart';
import 'token.dart';
import 'utils.dart';

typedef RouteEncode = String Function(String value);

/// Expose a function for taking tokens and returning a [RegExp].
RegExp tokensToRegExp(
  Iterable<Token> tokens, {
  List<MetadataToken>? metadata,
  bool sensitive = defatulSensitive,
  bool strict = defaultStrict,
  bool end = defaultEnd,
  bool start = defaultStart,
  String delimiter = defautlDelimiter,
  String endsWith = '',
  RouteEncode encode = defaultRouteEncode,
}) {
  final String resolvedEndsWith = '[${escapeRegExp(endsWith)}]|\$';
  final String resolvedDelimiter = '[${escapeRegExp(delimiter)}]';

  String route = start ? '^' : '';

  // Iterate over the tokens and create our regexp string.
  for (final Token token in tokens) {
    if (token is StringToken) {
      route += escapeRegExp(encode(token.value));
      continue;
    }

    token as MetadataToken;

    final String prefix = escapeRegExp(encode(token.prefix));
    final String suffix = escapeRegExp(encode(token.suffix));

    if (token.pattern.isNotEmpty) {
      // If [metadata] is not null, push the current token into it.
      if (metadata != null) {
        metadata.add(token);
      }

      if (prefix.isNotEmpty || suffix.isNotEmpty) {
        if (token.modifier == '+' || token.modifier == '*') {
          final String mod = token.modifier == '*' ? '?' : '';
          route +=
              '(?:$prefix((?:${token.pattern})(?:$suffix$prefix(?:${token.pattern}))*)$suffix)$mod';
        } else {
          route += '(?:$prefix(${token.pattern})$suffix)${token.modifier}';
        }
      } else {
        if (token.modifier == '+' || token.modifier == '*') {
          route += '((?:${token.pattern})${token.modifier})';
        } else {
          route += '(${token.pattern})${token.modifier}';
        }
      }
    } else {
      route += '(?:$prefix$suffix)${token.modifier}';
    }
  }

  if (end) {
    if (strict) {
      route += '$resolvedDelimiter?';
    }

    route += endsWith.isEmpty ? r'$' : '(?=$resolvedEndsWith)';
  } else {
    if (strict) {
      route += '(?:$resolvedDelimiter(?=$resolvedEndsWith))?';
    }

    final Token endToken = tokens.last;
    final bool isEndDelimited = endToken is StringToken &&
        resolvedDelimiter.contains(endToken.value[endToken.value.length - 1]);
    if (!isEndDelimited) {
      route += '(?=$resolvedDelimiter|$resolvedEndsWith)';
    }
  }

  return RegExp(route, caseSensitive: sensitive);
}
