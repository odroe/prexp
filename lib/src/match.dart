import 'constants.dart';
import 'default_encode.dart';
import 'path_to_regexp.dart';
import 'regexp_to_function.dart';
import 'token.dart';
import 'tokens_to_regexp.dart';
import 'types.dart';

MatchFunction<Params> match(
  Object input, {
  String delimiter = defautlDelimiter,
  String prefixes = defaultPrefixes,
  List<MetadataToken>? metadata,
  bool sensitive = defatulSensitive,
  bool strict = defaultStrict,
  bool end = defaultEnd,
  bool start = defaultStart,
  String endsWith = '',
  RouteEncode encode = defaultRouteEncode,
  MetadataParser decode = defaultMetadataParser,
}) {
  metadata ??= <MetadataToken>[];

  final RegExp pattern = pathToRegExp(input,
      metadata: metadata,
      sensitive: sensitive,
      strict: strict,
      end: end,
      start: start,
      delimiter: delimiter,
      prefixes: prefixes,
      endsWith: endsWith,
      encode: encode);

  return regExpToFunction(pattern, metadata: metadata, decode: decode);
}
