import 'prexp.dart';
import 'prexp_token.dart';
import 'types.dart';

/// Path matching result.
class PrexpMatch {
  final String path;
  final Map<String, dynamic> params;

  const PrexpMatch(this.path, this.params);

  @override
  String toString() => 'PrexpMatch($path, $params)';
}

/// Path matcher.
///
/// Match a path against a path expression.
class PathMatcher {
  /// Path regular expression.
  final RegExp regexp;

  /// Path expression metadata.
  final Iterable<MetadataPrexpToken> metadata;

  /// Segment decoder.
  final SegmentParser decoder;

  /// Create a new [PathMatcher] from a [RegExp].
  const PathMatcher.fromRegExp(
    this.regexp,
    this.metadata, {
    this.decoder = defaultSegmentParser,
  });

  /// Create a new [PathMatcher] from a [Prexp].
  PathMatcher.fromPrexp(
    Prexp prexp, {
    this.decoder = defaultSegmentParser,
  })  : regexp = prexp,
        metadata = prexp.metadata;

  /// Call match, return [PrexpMatch].
  Iterable<PrexpMatch> call(String path) =>
      regexp.allMatches(path).map(_matchHandler);

  /// Parse matched and create a [PrexpMatch].
  PrexpMatch _matchHandler(RegExpMatch match) {
    final String path = match.group(0)!;
    final Map<String, dynamic> params = {};

    for (int index = 1; index <= match.groupCount; index++) {
      final String? value = match.group(index);
      if (value == null) {
        continue;
      }

      final MetadataPrexpToken token = metadata.elementAt(index - 1);

      if (token.modifier == '*' || token.modifier == '+') {
        params[token.name] = value
            .split(token.prefix + token.suffix)
            .map((String segment) => decoder(segment, token));
      } else {
        params[token.name] = decoder(value, token);
      }
    }

    return PrexpMatch(path, params);
  }
}
