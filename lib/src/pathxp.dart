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

/// {@template path_result}
/// The result of an evaluated path.
/// {@endtemplate}
class PathResult {
  /// {@macro path_result}
  const PathResult({
    required this.path,
    this.repeating = false,
    this.infinite = false,
  });

  /// The path.
  final List<PathDirection> path;

  /// If the path is repeating or not.
  final bool repeating;

  /// If the path is infinite or not.
  final bool infinite;
}

/// {@template pathxp}
/// Like regular expressions but for defining paths in a grid
/// {@endtemplate}
class Pathxp {
  /// {@macro pathxp}
  Pathxp(this.expression);

  /// The raw expresion.
  final String expression;

  PathResult? _parsedPath;

  /// Returns the path from the expression.
  PathResult get path {
    return _parsedPath ??= _parseExpression();
  }

  PathResult _parseExpression() {
    final mainRegExp = RegExp('([RI]?){([TBLR0-9,]+)}');

    final match = mainRegExp.matchAsPrefix(expression.replaceAll(' ', ''));

    final modifiers = match?.group(1);

    final internalExpression = match?.group(2);

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

    return PathResult(
      path: parsedPath,
      repeating: modifiers?.contains('R') ?? false,
      infinite: modifiers?.contains('I') ?? false,
    );
  }
}
