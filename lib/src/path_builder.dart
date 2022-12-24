import 'dart:io';

import '_internal/constants.dart';
import '_internal/utils.dart';
import '_internal/parse.dart';
import 'token.dart';
import 'types.dart';

/// Path builder.
///
/// Converts a path expression, usually the path parsed [Iterable<Token>],
/// into a real through parameterized path.
///
/// ### With tokens
///
/// ```dart
/// final PathCompiler compiler = PathCompiler.tokens(tokens);
/// final String path = compiler({ 'name': 'bob' });
/// ```
///
/// ### With path
///
/// ```dart
/// final PathCompiler compiler = PathCompiler.path(r'/users/:name');
/// final String path = compiler({ 'name': 'bob' });
/// ```
class PathBuilder {
  /// Parsed path expression tokens.
  final Iterable<PrexpToken> tokens;

  /// [RegExp] case sensitive.
  ///
  /// If `true`, the regular expression is case sensitive.
  final bool caseSensitive;

  /// Segment encoder.
  ///
  /// Encode a segment value into a string.
  final SegmentParser encoder;

  /// Validate segment.
  final bool validate;

  /// Segment regular expressions.
  ///
  /// __NOTE__: Internal use only, for caching regular expressions.
  final Iterable<RegExp?> _regularExpressions;

  /// Create a new [PathBuilder] with tokens.
  PathBuilder.fromTokens(
    this.tokens, {
    this.caseSensitive = defatulCaseSensitive,
    this.encoder = segmentParser,
    this.validate = defaultValidate,
  }) : _regularExpressions = tokens.map((token) {
          if (token is MetadataPrexpToken) {
            return RegExp(token.pattern, caseSensitive: caseSensitive);
          }
          return null;
        });

  /// Create a new [PathBuilder] with path.
  ///
  /// @see [PathCompiler.withTokens]
  /// @see [parse]
  factory PathBuilder.fromPath(
    String path, {
    bool caseSensitive = defatulCaseSensitive,
    SegmentParser encoder = segmentParser,
    bool validate = defaultValidate,
    String delimiter = defautlDelimiter,
    String prefixes = defaultPrefixes,
  }) =>
      PathBuilder.fromTokens(
        parse(path, delimiter: delimiter, prefixes: prefixes),
        caseSensitive: caseSensitive,
        encoder: encoder,
        validate: validate,
      );

  /// build a path with parameters.
  ///
  /// Example:
  ///
  /// ```dart
  /// final PathCompiler compiler = PathCompiler.withPath(r'/users/:name');
  /// final String path = compiler({ 'name': 'bob' });
  /// ```
  String call([Map<String, dynamic>? parameters]) {
    final StringBuffer result = StringBuffer();

    for (int index = 0; index < tokens.length; index++) {
      final PrexpToken token = tokens.elementAt(index);

      if (token is StringPrexpToken) {
        result.write(token.value);
        continue;
      }

      token as MetadataPrexpToken;
      final dynamic value = parameters?[token.name];
      final bool optional = token.modifier == '?' || token.modifier == '*';
      final bool repeat = token.modifier == '*' || token.modifier == '+';

      if (value is Iterable) {
        _throwIf(!repeat,
            'Expected "${token.name}" to not repeat, but got an list.');

        if (value.isEmpty) {
          _throwIf(!optional, 'Expected "${token.name}" to not be empty.');
          continue;
        }

        _segmentBuilder(
            value, result, token, _regularExpressions.elementAt(index));
        continue;
      }

      if (value is String || value is num) {
        final String segment = encoder(value.toString(), token);

        _throwIf(
          validate &&
              !(_regularExpressions.elementAt(index)?.hasMatch(segment) ??
                  false),
          'Expected "${token.name}" to match "${token.pattern}", but got "$segment".',
        );

        result
          ..write(token.prefix)
          ..write(segment)
          ..write(token.suffix);
        continue;
      }

      _throwIf(
        !optional,
        'Expected "${token.name}" to be a String/num or an Iterable<String/num>, but got "$value".',
      );
    }

    return result.toString();
  }

  /// Segment builder.
  void _segmentBuilder(Iterable<dynamic> segments, StringBuffer result,
      MetadataPrexpToken token, RegExp? regExp) {
    for (final dynamic segment in segments) {
      final String value = encoder(segment.toString(), token);
      if (validate) {
        _throwIf(
          !regExp!.hasMatch(value),
          'Expected all "${token.name}" to match "${token.pattern}", but got "$value".',
        );
      }

      result
        ..write(token.prefix)
        ..write(value)
        ..write(token.suffix);
    }
  }

  /// If expression throw exception.
  void _throwIf(bool expression, String message) {
    if (expression) {
      throw FormatException(message);
    }
  }
}
