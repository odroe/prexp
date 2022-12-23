import 'constants.dart';
import 'default_encode.dart';
import 'parse.dart';
import 'tokens_to_function.dart';
import 'types.dart';

/// Compile a string to a template function for the path.
PathFunction<T> compile<T extends Params>(
  String path, {
  String delimiter = defautlDelimiter,
  String prefixes = defaultPrefixes,
  bool sensitive = defatulSensitive,
  MetadataParser encode = defaultMetadataParser,
  bool validate = defaultValidate,
}) {
  return tokensToFunction(
    sensitive: sensitive,
    encode: encode,
    validate: validate,
    parse(path, delimiter: delimiter, prefixes: prefixes),
  );
}
