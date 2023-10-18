// ignore_for_file: prefer_const_constructors
import 'package:pathxp/pathxp.dart';
import 'package:test/test.dart';

void main() {
  group('Pathxp', () {
    test('can be instantiated', () {
      expect(Pathxp(''), isNotNull);
    });

    test('can parse an expression with a single value', () {
      expect(
        Pathxp('{T}').path.path,
        equals([PathDirection.T]),
      );
    });

    test('can parse an expression with a many values', () {
      expect(
        Pathxp('{T, L, R}').path.path,
        equals([PathDirection.T, PathDirection.L, PathDirection.R]),
      );
    });

    test('can parse expression with numbers', () {
      expect(
        Pathxp('{1T, 2L, 4R}').path.path,
        equals(
          [
            PathDirection.T,
            PathDirection.L,
            PathDirection.L,
            PathDirection.R,
            PathDirection.R,
            PathDirection.R,
            PathDirection.R,
          ],
        ),
      );
    });

    test('throws when the expression is invalid', () {
      expect(
        () => Pathxp('1T, 2L, 4R}').path.path,
        throwsArgumentError,
      );

      expect(
        () => Pathxp('{A, 2L, 4R}').path.path,
        throwsArgumentError,
      );
      expect(
        () => Pathxp('{1BB}').path.path,
        throwsArgumentError,
      );
    });

    test('is repeating is false by default', () {
      expect(
        Pathxp('{T}').path.repeating,
        isFalse,
      );
    });

    test('can detect is repeating', () {
      final result = Pathxp('R{T}').path;
      expect(result.repeating, isTrue);
      expect(result.path, equals([PathDirection.T]));
    });

    test('can detect is repeating with multiple steps', () {
      final result = Pathxp('R{T, 2L}').path;
      expect(result.repeating, isTrue);
      expect(
        result.path,
        equals(
          [PathDirection.T, PathDirection.L, PathDirection.L],
        ),
      );
    });

    test('can detect is repeating with multiple steps and contains Right', () {
      final result = Pathxp('R{T, 2L, R}').path;
      expect(result.repeating, isTrue);
      expect(
        result.path,
        equals(
          [PathDirection.T, PathDirection.L, PathDirection.L, PathDirection.R],
        ),
      );
    });

    test('is infinite is false by default', () {
      expect(
        Pathxp('{T}').path.infinite,
        isFalse,
      );
    });

    test('can detect is infinite', () {
      final result = Pathxp('I{T}').path;
      expect(result.infinite, isTrue);
      expect(result.path, equals([PathDirection.T]));
    });

    test('can detect is infinite with multiple steps', () {
      final result = Pathxp('I{T, 2L}').path;
      expect(result.infinite, isTrue);
      expect(
        result.path,
        equals(
          [PathDirection.T, PathDirection.L, PathDirection.L],
        ),
      );
    });

    test('can detect is infinite with multiple steps and contains Right', () {
      final result = Pathxp('I{T, 2L, R}').path;
      expect(result.infinite, isTrue);
      expect(
        result.path,
        equals(
          [PathDirection.T, PathDirection.L, PathDirection.L, PathDirection.R],
        ),
      );
    });
  });
}
