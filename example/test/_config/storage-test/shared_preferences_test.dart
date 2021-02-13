import 'package:example/src/_config/storage/index.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('initializeSharedPref() test', () async {
    await initializeSharedPref();
    expect(sharedPreferences != null, true);
  });
}
