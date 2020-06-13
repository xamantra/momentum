import 'package:flutter_test/flutter_test.dart';

import 'utility.dart';
import 'widgets/blank_widget.dart';
import 'widgets/error_widget6.dart';
import 'widgets/error_widget7.dart';

void main() {
  testWidgets('null controller specified in momentum', (tester) async {
    var widget = errorWidget6();
    await inject(tester, widget);
    expect(tester.takeException(), isInstanceOf<Exception>());
  });

  testWidgets('null controllers and services', (tester) async {
    var widget = blankWidget();
    await inject(tester, widget);
    var blankText = find.text('Blank App');
    expect(blankText, findsOneWidget);
  });

  testWidgets('duplicate controller', (tester) async {
    var widget = errorWidget7();
    await inject(tester, widget);
    expect(tester.takeException(), isInstanceOf<Exception>());
  });
}
