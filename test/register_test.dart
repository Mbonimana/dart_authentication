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
    expect(2 + 6, 8);
  } 
  );
}
