import 'package:flutter_test/flutter_test.dart';

import 'utility.dart';
import 'widgets/error_widget.dart';

void main() {
  testWidgets('null builder parameter', (tester) async {
    var widget = errorWidget();
    await inject(tester, widget);
    expect(tester.takeException(), isInstanceOf<Exception>());
  });
}
