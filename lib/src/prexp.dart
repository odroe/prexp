import 'package:prexp/src/_internal/utils.dart';

import '_internal/constants.dart';
import '_internal/parse.dart' as parser;
import 'token.dart';

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
    Iterable<MetadataPrexpToken>? metadata,
    bool caseSensitive = defatulCaseSensitive,
    bool strict = defaultStrict,
    bool start = defaultStart,
    bool end = defaultEnd,
    String delimiter = defautlDelimiter,
    String? endsWith,
    SegmentEncoder? encoder,
  }) =>
      _PrexpFromTokensImpl(
        tokens,
        metadata: metadata,
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
  factory Prexp.fromRegExp(RegExp regexp,
          [Iterable<MetadataPrexpToken>? metadata]) =>
      _PrexpFromRegExpImpl(regexp, metadata);

  /// Create a [Prexp] from [String].
  ///
  /// ```dart
  /// final Prexp path = Prexp.fromString(r'/users/:name');
  /// print(path.hasMatch('/users/John')); // true
  /// print(path.metadata);
  /// ```
  factory Prexp.fromString(
    String path, {
    Iterable<MetadataPrexpToken>? metadata,
    bool caseSensitive = defatulCaseSensitive,
    bool strict = defaultStrict,
    bool end = defaultEnd,
    bool start = defaultStart,
    String delimiter = defautlDelimiter,
    String prefixes = defaultPrefixes,
    String? endsWith,
    SegmentEncoder? encoder,
  }) =>
      _PrexpFromStringImpl(
        path,
        metadata: metadata,
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
    Iterable<MetadataPrexpToken>? metadata,
    bool caseSensitive = defatulCaseSensitive,
    bool strict = defaultStrict,
    bool start = defaultStart,
    bool end = defaultEnd,
    String delimiter = defautlDelimiter,
    String? endsWith,
    SegmentEncoder? encoder,
  }) {
    encoder ??= (String segment) => segment;
    delimiter = '[${escapeRegExp(delimiter)}]';

    final String resolvedEndsWith = '[${escapeRegExp(endsWith ?? '')}]|\$2';

    final List<MetadataPrexpToken> metadataContainer = metadata?.toList() ?? [];
    final StringBuffer buffer = StringBuffer(start ? '^' : '');

    for (final PrexpToken token in tokens) {
      if (token is StringPrexpToken) {
        buffer.write(escapeRegExp(encoder(token.value)));
        continue;
      }

      token as MetadataPrexpToken;
      final String prefix = escapeRegExp(encoder(token.prefix));
      final String suffix = escapeRegExp(encoder(token.suffix));

      buffer.writeAll([
        callIf<String>(
          token.pattern.isNotEmpty,
          () {
            metadataContainer.add(token);

            return callIf<String>(
              prefix.isNotEmpty || suffix.isNotEmpty,
              () => callIf<String>(
                token.modifier == '+' || token.modifier == '*',
                () =>
                    '(?:$prefix((?:${token.pattern})(?:$suffix$prefix(?:${token.pattern}))*)$suffix)${token.modifier == '*' ? '?' : ''}',
                () => '(?:$prefix(${token.pattern})$suffix)${token.modifier}',
              ),
              () => callIf<String>(
                token.modifier == '+' || token.modifier == '*',
                () => '((?:${token.pattern})${token.modifier})',
                () => '(${token.pattern})${token.modifier}',
              ),
            );
          },
          () => '(?:$prefix$suffix)${token.modifier}',
        ),
        callIf<String>(
          end,
          () {
            final StringBuffer segmentBuffer =
                StringBuffer(strict ? '$delimiter?' : '');

            segmentBuffer.write(callIf<String>(
                endsWith?.isEmpty ?? true, () => r'$', () => resolvedEndsWith));

            return segmentBuffer.toString();
          },
          () {
            final StringBuffer segmentBuffer = StringBuffer(
                strict ? '(?:$delimiter(?=$resolvedEndsWith))?' : '');
            final PrexpToken lastToken = tokens.last;
            if (lastToken is StringPrexpToken &&
                delimiter
                    .contains(lastToken.value[lastToken.value.length - 1])) {
              segmentBuffer.write('(?=$delimiter|$resolvedEndsWith)');
            }

            return segmentBuffer.toString();
          },
        ),
      ]);
    }

    return _PrexpFromTokensImpl._internal(
      RegExp(buffer.toString(), caseSensitive: caseSensitive),
      metadataContainer,
    );
  }

  static T callIf<T>(
      bool expression, T Function() handler, T Function() elseHandler) {
    if (expression) {
      return handler();
    }

    return elseHandler();
  }
}

/// Implementation of [Prexp] from [RegExp].
class _PrexpFromRegExpImpl extends _PrexpImpl {
  _PrexpFromRegExpImpl._internal(super.original, super.metadata);

  factory _PrexpFromRegExpImpl(RegExp regexp,
      [Iterable<MetadataPrexpToken>? metadata]) {
    if (metadata == null) {
      return _PrexpFromRegExpImpl._internal(
          regexp, regexp is Prexp ? regexp.metadata : []);
    }

    int index = 0;
    final Iterable<RegExpMatch> matches =
        groupRegExp.allMatches(regexp.pattern);
    final List<MetadataPrexpToken> metadataStore = metadata.toList();

    for (final RegExpMatch match in matches) {
      final MetadataPrexpToken token = MetadataPrexpToken(
        name: match.group(1) ?? (index++).toString(),
        prefix: '',
        suffix: '',
        modifier: '',
        pattern: '',
      );
      metadataStore.add(token);
    }

    return _PrexpFromRegExpImpl._internal(regexp, metadataStore);
  }

  static final RegExp groupRegExp = RegExp(r'\((?:\?<(.*?)>)?(?!\?)');
}

/// Implementation of [Prexp] from [String].
class _PrexpFromStringImpl extends _PrexpImpl {
  _PrexpFromStringImpl._internal(super.original, super.metadata);

  factory _PrexpFromStringImpl(
    String path, {
    Iterable<MetadataPrexpToken>? metadata,
    bool caseSensitive = defatulCaseSensitive,
    bool strict = defaultStrict,
    bool end = defaultEnd,
    bool start = defaultStart,
    String delimiter = defautlDelimiter,
    String prefixes = defaultPrefixes,
    String? endsWith,
    SegmentEncoder? encoder,
  }) {
    final Iterable<PrexpToken> tokens =
        Prexp.parse(path, prefixes: prefixes, delimiter: delimiter);
    final Prexp prexp = Prexp.fromTokens(
      tokens,
      metadata: metadata,
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
