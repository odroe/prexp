# Prexp

Prexp (**P**ath to **re**gular **exp**ression) is a Dart package that converts a path to a regular expression.

```dart
import 'package:prexp/prexp.dart';

void main() {
  final String route = r'/users/:name';

  final Prexp prexp = Prexp.fromString(route);
  print(prexp.hasMatch('/users/odroe')); // true

  final PathMatcher matcher = PathMatcher.fromPrexp(prexp);
  print(matcher('/users/odroe')); // (PrexpMatch(/users/Seven, {name: Seven}))

  final PathBuilder builder = PathBuilder.fromPath(route);
  print(builder({'name': 'odroe'})); // /users/odroe

  print(Prexp.parse(
      route)); // [StringPrexpToken(/users), MetadataPrexpToken({"name":"name","prefix":"/","suffix":"","pattern":"[^\\/#\\?]+?","modifier":""}]
}
```

## Installation

Add this to your package's pubspec.yaml file:

```yaml
dependencies:
  prexp: latest
```

Or install it from the command line:

```bash
dart pub add prexp
```

## Create a list of `PrexpToken`

The `Prexp.parse` static utility to create an list of `PrexpToken` from a path.

```dart
final Iterable<PrexpToken> tokens = Prexp.parse('/users/:name');
```

##### Optional parameters

- `delimiter` - The delimiter between segments. Defaults to `/#?`.
- `prefixes` - The prefixes to use when parsing a path. Defaults to `./`.

## `Prexp` class

`Prexp` implements the `RegExp` interface and is compatible with `RegExp`. The only difference between `Prexp` and `RegExp` is that `Prexp` contains the parameter source information of path.

```dart
final Prexp prexp = Prexp.fromString('/users/:name');

print(prexp.hasMatch('/users/odroe')); // true
print(prexp is RegExp); // true
print(prexp.metadata); // MetadataPrexpToken({"name":"name","prefix":"/","suffix":"","pattern":"[^\\/#\\?]+?","modifier":""})
```

#### Create a `Prexp` from a string

```dart
final Prexp prexp = Prexp.fromString('/users/:name');
```

#### Create a `Prexp` from a `RegExp`

```dart
final RegExp regexp = ...;
final Prexp prexp = Prexp.fromRegExp(regexp);
```

#### Create a `Prexp` from a list of `PrexpToken`

```dart
final Iterable<PrexpToken> tokens = Prexp.parse('/users/:name');
final Prexp prexp = Prexp.fromTokens(tokens);
```

## Path builder

The `PathBuilder` class is used to build a path from a map of parameters.

#### Create a `PathBuilder` from a path

```dart
final PathBuilder builder = PathBuilder.fromPath('/users/:name');

print(builder({'name': 'odroe'})); // /users/odroe
```

#### Create a `PathBuilder` from list of `PrexpToken`

```dart
final Iterable<PrexpToken> tokens = Prexp.parse('/users/:name');
final PathBuilder builder = PathBuilder.fromTokens(tokens);

print(builder({'name': 'odroe'})); // /users/odroe
```

## Path matcher

The `PathMatcher` class is used to match a path against a route.

#### Create a `PathMatcher` from a `Prexp`

```dart
final Prexp prexp = Prexp.fromString('/users/:name');
final PathMatcher matcher = PathMatcher.fromPrexp(prexp);

print(matcher('/users/odroe')); // (PrexpMatch(/users/odroe, {name: odroe}))
```

#### Create a `PathMatcher` from a `RegExp`

```dart
final RegExp regexp = ...;
final Iterable<MetadataPrexpToken> metadata = ...;
final PathMatcher matcher = PathMatcher.fromRegExp(regexp, metadata);

print(matcher('/users/odroe'));
```

#### Match a path against a route

```dart

final PathMatcher matcher = ...;
final Iterable<PrexpMatch> matches = matcher('/users/odroe');

print(matches); // (PrexpMatch(/users/odroe, {name: odroe}))
```

> __Note__: If the path does not match the route, the `PathMatcher` returns an empty list.

