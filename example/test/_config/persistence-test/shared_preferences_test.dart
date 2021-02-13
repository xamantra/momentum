import 'package:example/src/_config/persistence/index.dart';
import 'package:example/src/_config/storage/index.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Presistence test for SharedPreferences', () async {
    await initializeSharedPref();

    var saved = await persistSave_SharedPref(null, 'test1', 'value1');
    expect(saved, true);

    var value1 = await persistGet_SharedPref(null, 'test1');
    expect(value1, 'value1');
  });
}
