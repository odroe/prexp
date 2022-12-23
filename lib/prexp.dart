/// Path to regular expression.
///
/// This library provides a way to convert a path to a regular expression.
///
/// The path can contain named parameters, which will be parsed and returned
/// as a map of key-value pairs.
library prexp;

export 'src/compile.dart';
export 'src/parse.dart';

export 'src/match_result.dart';
export 'src/match.dart';

export 'src/path_to_regexp.dart';
export 'src/regexp_to_function.dart';
export 'src/tokens_to_regexp.dart';
export 'src/tokens_to_function.dart';

export 'src/token.dart';
export 'src/types.dart';
