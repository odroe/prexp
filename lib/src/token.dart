import 'dart:convert';

/// Prexp token
abstract class PrexpToken {}

/// String token.
class StringPrexpToken implements PrexpToken {
  final String value;

  StringPrexpToken(this.value);

  @override
  String toString() => 'StringPrexpToken($value)';
}

/// Metedata token.
class MetadataPrexpToken implements PrexpToken {
  final String name;
  final String prefix;
  final String suffix;
  final String pattern;
  final String modifier;

  const MetadataPrexpToken({
    required this.name,
    required this.prefix,
    required this.suffix,
    required this.pattern,
    required this.modifier,
  });

  @override
  String toString() => 'MetadataPrexpToken(${json.encode({
            'name': name,
            'prefix': prefix,
            'suffix': suffix,
            'pattern': pattern,
            'modifier': modifier,
          })}';
}
