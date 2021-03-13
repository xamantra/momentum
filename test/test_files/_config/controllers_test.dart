import 'package:flutter_test/flutter_test.dart';

import '../../demo_app/_config/index.dart';

void main() {
  test('Controllers config test', () {
    expect(controllers().isNotEmpty, true);
  });
}
