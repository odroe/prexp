import 'package:prexp/prexp.dart';

void main() {
  final String route = r'/users/:name';

  final Prexp prexp = Prexp.fromString(route);
  print(prexp.hasMatch('/users/odroe')); // true

  final PathMatcher matcher = PathMatcher.fromPrexp(prexp);
  print(matcher('/users/odroe')); // (PrexpMatch(/users/odroe, {name: Seven}))

  final PathBuilder builder = PathBuilder.fromPath(route);
  print(builder({'name': 'odroe'})); // /users/odroe

  print(Prexp.parse(
      route)); // [StringPrexpToken(/users), MetadataPrexpToken({"name":"name","prefix":"/","suffix":"","pattern":"[^\\/#\\?]+?","modifier":""}]
}
