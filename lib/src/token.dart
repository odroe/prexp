abstract class Token {}

/// String token.
class StringToken implements Token {
  final String value;

  StringToken(this.value);

  @override
  String toString() => 'StringToken($value)';
}

/// Metedata token.
class MetadataToken implements Token {
  final String name;
  final String prefix;
  final String suffix;
  final String pattern;
  final String modifier;

  const MetadataToken({
    required this.name,
    required this.prefix,
    required this.suffix,
    required this.pattern,
    required this.modifier,
  });

  @override
  String toString() =>
      'MetadataToken($name, $prefix, $suffix, $pattern, $modifier)';
}
