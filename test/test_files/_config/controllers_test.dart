import 'package:flutter_test/flutter_test.dart';

import '../../demo_app/src/_config/index.dart';

void main() {
  test('Controllers config test', () {
    expect(controllers() != null, true);
    expect(controllers().isNotEmpty, true);
  });
}
