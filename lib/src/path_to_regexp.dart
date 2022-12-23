import 'constants.dart';
import 'default_encode.dart';
import 'parse.dart';
import 'token.dart';
import 'tokens_to_regexp.dart';

/// Create a path regexp from string input.
RegExp stringToRegExp(
  String path, {
  List<MetadataToken>? metadata,
  bool sensitive = defatulSensitive,
  bool strict = defaultStrict,
  bool end = defaultEnd,
  bool start = defaultStart,
  String delimiter = defautlDelimiter,
  String prefixes = defaultPrefixes,
  String endsWith = '',
  RouteEncode encode = defaultRouteEncode,
}) {
  return tokensToRegExp(
    parse(path, delimiter: delimiter, prefixes: prefixes),
    metadata: metadata,
    sensitive: sensitive,
    strict: strict,
    end: end,
    start: start,
    delimiter: delimiter,
    endsWith: endsWith,
    encode: encode,
  );
}

/// Pull out keys from a regexp.
RegExp regExpToRegExp(RegExp regExp, [List<MetadataToken>? metadata]) {
  if (metadata == null) {
    return regExp;
  }

  final RegExp groupRegExp = RegExp(r'\((?:\?<(.*?)>)?(?!\?)');

  int index = 0;
  final Iterable<RegExpMatch> matches = groupRegExp.allMatches(regExp.pattern);
  for (final RegExpMatch match in matches) {
    final MetadataToken token = MetadataToken(
      name: match.group(1) ?? (index++).toString(),
      prefix: '',
      suffix: '',
      modifier: '',
      pattern: '',
    );
    metadata.add(token);
  }

  return regExp;
}

/// Transform an [Iterable<dynamic>] into a regexp.
///
/// The [Iteravle] children can be [String]s or [RegExp]s.
RegExp listToRegExp(
  Iterable<Object> iterable, {
  List<MetadataToken>? metadata,
  bool sensitive = defatulSensitive,
  bool strict = defaultStrict,
  bool end = defaultEnd,
  bool start = defaultStart,
  String delimiter = defautlDelimiter,
  String prefixes = defaultPrefixes,
  String endsWith = '',
  RouteEncode encode = defaultRouteEncode,
}) {
  final parts = iterable
      .map((child) => pathToRegExp(
            child,
            metadata: metadata,
            sensitive: sensitive,
            strict: strict,
            end: end,
            start: start,
            delimiter: delimiter,
            prefixes: prefixes,
            endsWith: endsWith,
            encode: encode,
          ).pattern)
      .join('|');

  return RegExp('(?:$parts)', caseSensitive: sensitive);
}

/// Normalize the given path string, returning a regular expression.
RegExp pathToRegExp(
  Object path, {
  List<MetadataToken>? metadata,
  bool sensitive = defatulSensitive,
  bool strict = defaultStrict,
  bool end = defaultEnd,
  bool start = defaultStart,
  String delimiter = defautlDelimiter,
  String prefixes = defaultPrefixes,
  String endsWith = '',
  RouteEncode encode = defaultRouteEncode,
}) {
  if (path is RegExp) {
    return regExpToRegExp(path, metadata);
  } else if (path is Iterable<Object>) {
    return listToRegExp(
      path,
      metadata: metadata,
      sensitive: sensitive,
      strict: strict,
      end: end,
      start: start,
      delimiter: delimiter,
      prefixes: prefixes,
      endsWith: endsWith,
      encode: encode,
    );
  } else if (path is String) {
    return stringToRegExp(
      path,
      metadata: metadata,
      sensitive: sensitive,
      strict: strict,
      end: end,
      start: start,
      delimiter: delimiter,
      prefixes: prefixes,
      endsWith: endsWith,
      encode: encode,
    );
  }

  throw ArgumentError.value(
      path, 'path', 'must be a String/RegExp or Iterable<Object>');
}
