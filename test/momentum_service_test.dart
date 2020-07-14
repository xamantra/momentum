import 'package:flutter_test/flutter_test.dart';

import 'utilities/launcher.dart';
import 'widgets/service.dart';

void main() {
  testWidgets('Grab other service.', (tester) async {
    var widget = serviceWidget();
    await launch(tester, widget);
    var serviceA = widget.serviceForTest<ServiceA>();
    expect(serviceA, isInstanceOf<ServiceA>());
    var result = serviceA.increment(5);
    expect(result, 6);
    var resultFromServiceB = serviceA.times2(10);
    expect(resultFromServiceB, 20);
  });
}
