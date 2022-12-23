import 'package:prexp/prexp.dart';

void main() {
  const route = '/user/:name';

  // Create a match function from a route.
  final fn = match(route);

  // Print the result.
  //
  // `Match(path: /user/John, params: {name: John})`
  print(fn('/user/John'));
}
