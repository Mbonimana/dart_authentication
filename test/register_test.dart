import 'dart:convert';

import 'package:test/test.dart';

void main() {
  test('JSON parsing works', () {
    final jsonString = '{"username":"manasseh-test","email":"test@test.com"}';

    final data = jsonDecode(jsonString);

    expect(data['username'], 'manasseh-test');
    expect(data['email'], 'test@test.com');
  });

  test('addition',
      () {
    expect(2 + 6, 4);
  }
  );

  // Comprehensive tests for the addition functionality introduced in this PR
  group('addition - correct arithmetic coverage', () {
    test('2 + 6 equals 8', () {
      expect(2 + 6, 8);
    });

    test('addition with zero returns same number', () {
      expect(5 + 0, 5);
      expect(0 + 5, 5);
    });

    test('addition of two zeros is zero', () {
      expect(0 + 0, 0);
    });

    test('addition is commutative', () {
      expect(2 + 6, 6 + 2);
    });

    test('addition with negative numbers', () {
      expect(-3 + 3, 0);
      expect(-5 + 2, -3);
      expect(10 + (-4), 6);
    });

    test('addition with large integers', () {
      expect(1000000 + 999999, 1999999);
    });

    test('addition is associative', () {
      expect((1 + 2) + 3, 1 + (2 + 3));
    });

    test('adding negative to itself doubles magnitude', () {
      expect(-7 + (-7), -14);
    });

    test('adding a number to its negation yields zero', () {
      expect(42 + (-42), 0);
    });

    test('boundary: adding max-like and 1', () {
      const base = 999999999;
      expect(base + 1, 1000000000);
    });
  });
}
