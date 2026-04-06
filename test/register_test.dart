import 'dart:convert';

import 'package:test/test.dart';

void main() {
  test('JSON parsing works', () {
    final jsonString = '{"username":"manasseh","email":"test@test.com"}';

    final data = jsonDecode(jsonString);

    expect(data['username'], 'manasseh');
    expect(data['email'], 'test@test.com');
  });
}
