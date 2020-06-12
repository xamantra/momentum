import 'package:flutter_test/flutter_test.dart';

import 'components/counter/index.dart';
import 'utility.dart';
import 'widgets/counter.dart';

void main() {
  testWidgets('Initialize Controller', (tester) async {
    var widget = counter();
    await inject(tester, widget);
    var controller = widget.controllerForTest<CounterController>();
    expect(controller.model.value, 0);
  });
}
