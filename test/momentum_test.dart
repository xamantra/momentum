import 'package:flutter_test/flutter_test.dart';

import 'utility.dart';
import 'widgets/error_widget6.dart';

void main() {
  testWidgets('null controller specified in momentum', (tester) async {
    var widget = errorWidget6();
    await inject(tester, widget);
    expect(tester.takeException(), isInstanceOf<Exception>());
  });
}
