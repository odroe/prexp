import 'types.dart';

abstract class MatchResult<T extends Params> {}

/// Non-matched result.
class NoMatch implements MatchResult<Params> {
  const NoMatch();
}

/// Matched result.
class Match<T extends Params> implements MatchResult {
  final String path;
  final int index;
  final T params;

  const Match(this.path, this.index, this.params);

  @override
  String toString() => 'Match(path: $path, index: $index, params: $params)';
}
