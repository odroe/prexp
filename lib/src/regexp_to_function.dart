import 'default_encode.dart';
import 'match_result.dart';
import 'token.dart';
import 'types.dart';

typedef MatchFunction<T extends Params> = MatchResult<T> Function(String path);

/// Create a path match function from path to regexp output.
MatchFunction<Params> regExpToFunction(
  RegExp regExp, {
  required List<MetadataToken> metadata,
  MetadataParser decode = defaultMetadataParser,
}) =>
    (String input) {
      final RegExpMatch? match = regExp.firstMatch(input);

      if (match == null) {
        return const NoMatch();
      }

      final path = match.group(0)!;
      final Params params = {};

      for (int index = 1; index <= match.groupCount; index++) {
        final String? matchedValue = match.group(index);
        if (matchedValue == null) {
          continue;
        }

        final MetadataToken token = metadata[index - 1];
        if (token.modifier == '*' || token.modifier == '+') {
          params[token.name] = matchedValue
              .split(token.prefix + token.suffix)
              .map((String segment) => decode(segment, token));
        } else {
          params[token.name] = decode(matchedValue, token);
        }
      }

      return Match(path, 0, params);
    };
