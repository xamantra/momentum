import 'package:example/src/_config/index.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Services config test', () {
    expect(services() != null, true);
    expect(services().isNotEmpty, true);
  });
}
