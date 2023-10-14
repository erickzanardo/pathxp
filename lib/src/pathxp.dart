/// The direction of a path.
enum PathDirection {
  /// Indicates a path that goes up (Top).
  T,

  /// Indicates a path that goes down (Bottom).
  B,

  /// Indicates a path that goes left (Left).
  L,

  /// Indicates a path that goes right (Right).
  R;

  /// Returns a [PathDirection] from a string.
  static PathDirection fromString(String value) {
    return PathDirection.values.firstWhere(
      (e) => e.toString().split('.')[1] == value,
    );
  }
}

/// {@template pathxp}
/// Like regular expressions but for defining paths in a grid
/// {@endtemplate}
class Pathxp {
  /// {@macro pathxp}
  Pathxp(this.expression);

  /// The raw expresion.
  final String expression;

  List<PathDirection>? _parsedPath;

  /// Returns the path from the expression.
  List<PathDirection> get path {
    return _parsedPath ??= _parseExpression();
  }

  List<PathDirection> _parseExpression() {
    final mainRegExp = RegExp('{([TBLR0-9,]+)}');
    final internalExpression =
        mainRegExp.matchAsPrefix(expression.replaceAll(' ', ''))?.group(1);

    if (internalExpression == null) {
      throw ArgumentError('Invalid path expression: $expression');
    }

    final partRegExp = RegExp(r'([0-9]+)?([TBLR])$');

    final parts = internalExpression.split(',');

    final parsedPath = <PathDirection>[];

    for (final part in parts) {
      final match = partRegExp.matchAsPrefix(part);

      if (match == null) {
        throw ArgumentError('Unknow token: $part');
      }

      final count = int.parse(match.group(1) ?? '1');
      final direction = match.group(2)!;

      parsedPath.addAll(
        List<PathDirection>.filled(
          count,
          PathDirection.fromString(direction),
        ),
      );
    }

    return parsedPath;
  }
}
