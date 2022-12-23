# Prexp (Path to Regular Expression)

```dart
import 'package:prexp/prexp.dart';

void main() {
  final fn = match('/users/:name');
  print(fn('/users/John'));
}
```