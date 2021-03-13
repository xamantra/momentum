import 'package:flutter_test/flutter_test.dart';

import '../../../demo_app/src/_config/storage/index.dart';

void main() {
  test('initializeSharedPref() test', () async {
    await initializeSharedPref();
    expect(sharedPreferences != null, true);
  });
}
