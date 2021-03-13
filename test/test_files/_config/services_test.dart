import 'package:flutter_test/flutter_test.dart';

import '../../demo_app/_config/index.dart';

void main() {
  test('Services config test', () {
    expect(services() != null, true);
    expect(services().isNotEmpty, true);
  });
}
