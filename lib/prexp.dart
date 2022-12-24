/// Path to regular expression.
///
/// This library provides a way to convert a path to a regular expression.
///
/// The path can contain named parameters, which will be parsed and returned
/// as a map of key-value pairs.
library prexp;

export 'src/path_builder.dart';
export 'src/path_matcher.dart';
export 'src/prexp.dart';
export 'src/token.dart';
export 'src/types.dart';
