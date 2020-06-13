import 'package:flutter_test/flutter_test.dart';

import 'components/counter/index.dart';
import 'utility.dart';
import 'widgets/counter.dart';

void main() {
  testWidgets('Initialize Model', (tester) async {
    var widget = counter();
    await inject(tester, widget, milliseconds: 2000);
    var controller = widget.controllerForTest<CounterController>();
    expect(controller.model == null, false);
    expect(controller.model.value, 0);
  });
}
