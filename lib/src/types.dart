import 'prexp_token.dart';

typedef SegmentParser = String Function(String value, MetadataPrexpToken token);

/// Default segment parser.
String defaultSegmentParser(String value, MetadataPrexpToken token) => value;
