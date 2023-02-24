import '_internal/constants.dart';
import '_internal/parse.dart' as parser;
import 'prexp_token.dart';

typedef SegmentEncoder = String Function(String segment);

/// Path to regular expression.
///
/// ```dart
/// final Prexp path = Prexp.forPath(r'/users/:name');
///
/// print(path.hasMatch('/users/John')); // true
/// print(path.metadata);
/// ```
abstract class Prexp implements RegExp {
  /// Parsed path expression metadata.
  Iterable<MetadataPrexpToken> get metadata;

  /// Create a [Prexp] from [Iterable<Token>].
  ///
  /// ```dart
  /// final Prexp path = Prexp.fromTokens([
  ///  ...
  /// ]);
  ///
  /// print(path.hasMatch('/users/John')); // true
  /// print(path.metadata);
  /// ```
  factory Prexp.fromTokens(
    Iterable<PrexpToken> tokens, {
    bool caseSensitive = defatulCaseSensitive,
    bool strict = defaultStrict,
    bool start = defaultStart,
    bool end = defaultEnd,
    String delimiter = defautlDelimiter,
    String endsWith = '',
    SegmentEncoder? encoder,
  }) =>
      _PrexpFromTokensImpl(
        tokens,
        caseSensitive: caseSensitive,
        strict: strict,
        start: start,
        end: end,
        delimiter: delimiter,
        endsWith: endsWith,
        encoder: encoder,
      );

  /// Create a [Prexp] from [RegExp].
  ///
  /// ```dart
  /// final Prexp path = Prexp.fromRegExp(RegExp(r'/users/(.*?)'));
  ///
  /// print(path.hasMatch('/users/John')); // true
  /// print(path.metadata);
  /// ```
  factory Prexp.fromRegExp(RegExp regexp) => _PrexpFromRegExpImpl(regexp);

  /// Create a [Prexp] from [String].
  ///
  /// ```dart
  /// final Prexp path = Prexp.fromString(r'/users/:name');
  /// print(path.hasMatch('/users/John')); // true
  /// print(path.metadata);
  /// ```
  factory Prexp.fromString(
    String path, {
    bool caseSensitive = defatulCaseSensitive,
    bool strict = defaultStrict,
    bool end = defaultEnd,
    bool start = defaultStart,
    String delimiter = defautlDelimiter,
    String prefixes = defaultPrefixes,
    String endsWith = '',
    SegmentEncoder? encoder,
  }) =>
      _PrexpFromStringImpl(
        path,
        caseSensitive: caseSensitive,
        strict: strict,
        end: end,
        start: start,
        delimiter: delimiter,
        prefixes: prefixes,
        endsWith: endsWith,
        encoder: encoder,
      );

  /// Static utility method to create an [PrexpToken]s from [String].
  ///
  /// ```dart
  /// final Iterable<PrexpToken> tokens = Prexp.parse(r'/users/:name');
  ///
  /// print(tokens);
  /// ```
  static Iterable<PrexpToken> parse(
    String path, {
    String delimiter = defautlDelimiter,
    String prefixes = defaultPrefixes,
  }) =>
      parser.parse(path, delimiter: delimiter, prefixes: prefixes);
}

/// Implementation of [Prexp], which is a wrapper of [RegExp].
abstract class _PrexpImpl implements Prexp {
  const _PrexpImpl(this._original, this.metadata);

  /// Internal original [RegExp].
  final RegExp _original;

  @override
  final Iterable<MetadataPrexpToken> metadata;

  @override
  Iterable<RegExpMatch> allMatches(String input, [int start = 0]) =>
      _original.allMatches(input, start);

  @override
  RegExpMatch? firstMatch(String input) => _original.firstMatch(input);

  @override
  bool hasMatch(String input) => _original.hasMatch(input);

  @override
  Match? matchAsPrefix(String string, [int start = 0]) =>
      _original.matchAsPrefix(string, start);

  @override
  String? stringMatch(String input) => _original.stringMatch(input);

  @override
  bool get isCaseSensitive => _original.isCaseSensitive;

  @override
  bool get isDotAll => _original.isDotAll;

  @override
  bool get isMultiLine => _original.isMultiLine;

  @override
  bool get isUnicode => _original.isUnicode;

  @override
  String get pattern => _original.pattern;
}

/// Implementation of [Prexp] from [Iterable<Token>].
class _PrexpFromTokensImpl extends _PrexpImpl {
  _PrexpFromTokensImpl._internal(super.original, super.metadata);

  factory _PrexpFromTokensImpl(
    Iterable<PrexpToken> tokens, {
    bool caseSensitive = defatulCaseSensitive,
    bool strict = defaultStrict,
    bool start = defaultStart,
    bool end = defaultEnd,
    String delimiter = defautlDelimiter,
    String endsWith = '',
    SegmentEncoder? encoder,
  }) {
    encoder ??= (String segment) => segment;
    String route = start ? '^' : '';

    final List<MetadataPrexpToken> metadata = [];
    final String endsWithRe = '[${RegExp.escape(endsWith)}]|\$';
    final String delimiterRe = '[${RegExp.escape(delimiter)}]';

    for (final PrexpToken token in tokens) {
      if (token is StringPrexpToken) {
        route += RegExp.escape(encoder(token.value));
        continue;
      }

      token as MetadataPrexpToken;
      final String prefix = RegExp.escape(encoder(token.prefix));
      final String suffix = RegExp.escape(encoder(token.suffix));

      if (token.pattern.isNotEmpty) {
        metadata.add(token);

        if (prefix.isNotEmpty || suffix.isNotEmpty) {
          if (token.modifier == '*' || token.modifier == '+') {
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
      if (!strict) {
        route += '$delimiterRe?';
      }

      route += endsWith.isEmpty ? r"$" : '(?=$endsWithRe)';
    } else {
      final PrexpToken endToken = tokens.last;
      final bool isEndDelimited = endToken is StringPrexpToken
          ? delimiterRe.contains(endToken.value.substring(-1))
          : false;

      if (!strict) {
        route += '(?:$delimiterRe(?=$endsWithRe))?';
      }
      if (!isEndDelimited) {
        route += '(?=$delimiterRe|$endsWithRe)';
      }
    }

    return _PrexpFromTokensImpl._internal(
        RegExp(route, caseSensitive: caseSensitive), metadata);
  }
}

/// Implementation of [Prexp] from [RegExp].
class _PrexpFromRegExpImpl extends _PrexpImpl {
  _PrexpFromRegExpImpl._internal(super.original, super.metadata);

  factory _PrexpFromRegExpImpl(RegExp regexp) {
    int index = 0;
    final Iterable<RegExpMatch> matches =
        groupRegExp.allMatches(regexp.pattern);
    final List<MetadataPrexpToken> metadata = [];

    for (final RegExpMatch match in matches) {
      final MetadataPrexpToken token = MetadataPrexpToken(
        name: match.group(1) ?? (index++).toString(),
        prefix: '',
        suffix: '',
        modifier: '',
        pattern: '',
      );
      metadata.add(token);
    }

    return _PrexpFromRegExpImpl._internal(regexp, metadata);
  }

  static final RegExp groupRegExp = RegExp(r'\((?:\?<(.*?)>)?(?!\?)');
}

/// Implementation of [Prexp] from [String].
class _PrexpFromStringImpl extends _PrexpImpl {
  _PrexpFromStringImpl._internal(super.original, super.metadata);

  factory _PrexpFromStringImpl(
    String path, {
    bool caseSensitive = defatulCaseSensitive,
    bool strict = defaultStrict,
    bool end = defaultEnd,
    bool start = defaultStart,
    String delimiter = defautlDelimiter,
    String prefixes = defaultPrefixes,
    String endsWith = '',
    SegmentEncoder? encoder,
  }) {
    final Iterable<PrexpToken> tokens =
        Prexp.parse(path, prefixes: prefixes, delimiter: delimiter);
    final Prexp prexp = Prexp.fromTokens(
      tokens,
      caseSensitive: caseSensitive,
      strict: strict,
      start: start,
      end: end,
      delimiter: delimiter,
      endsWith: endsWith,
      encoder: encoder,
    );

    return _PrexpFromStringImpl._internal(prexp, prexp.metadata);
  }
}
