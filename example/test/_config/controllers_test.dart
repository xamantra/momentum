import 'package:example/src/_config/index.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Controllers config test', () {
    expect(controllers() != null, true);
    expect(controllers().isNotEmpty, true);
  });
}
