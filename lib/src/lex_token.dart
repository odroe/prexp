import 'lex_type.dart';

/// Lexical Token.
class LexToken {
  /// Lexical type.
  final LexType type;

  /// Lexical value.
  final String value;

  /// Lexical value index.
  final int index;

  /// Lexical token constructor.
  const LexToken(this.type, this.index, this.value);

  @override
  String toString() => 'LexToken($type, $index, $value)';
}
