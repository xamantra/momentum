import 'package:flutter_test/flutter_test.dart';

import 'components/async-test/async-test.controller.dart';
import 'components/counter/index.dart';
import 'components/dummy/index.dart';
import 'utility.dart';
import 'widgets/async.dart';
import 'widgets/counter.dart';

void main() {
  testWidgets('Initialize Controller', (tester) async {
    var widget = counter();
    await inject(tester, widget);
    var controller = widget.controllerForTest<CounterController>();
    expect(controller.model.value, 0);
  });

  // method tests
  testWidgets('config(...)', (tester) async {
    var widget = counter();
    await inject(tester, widget);
    var controller = widget.controllerForTest<CounterController>()
      ..config(
        lazy: false,
        enableLogging: true,
        maxTimeTravelSteps: 3,
      );
    expect(controller.isLazy, false);
    expect(controller.loggingEnabled, true);
    expect(controller.maxTimeTravelSteps, 3);
  });
  testWidgets('init()', (tester) async {
    var widget = asyncApp();
    await inject(tester, widget);
    var controller = widget.controllerForTest<AsyncTestController>();
    var init = controller.init();
    expect(init.value, 0);
    expect(init.name, '');
  });
  testWidgets('bootstrap()', (tester) async {
    var widget = asyncApp();
    await inject(tester, widget, milliseconds: 2000);
    var controller = widget.controllerForTest<AsyncTestController>();
    controller.bootstrap();
    expect(controller.model.value, 1);
    expect(controller.model.name, 'momentum');
  });
  testWidgets('bootstrapAsync()', (tester) async {
    var widget = asyncApp(lazy: false);
    await inject(tester, widget, milliseconds: 5000);
    var controller = widget.controllerForTest<AsyncTestController>();
    await controller.bootstrapAsync();
    expect(controller.model.value, 2);
    expect(controller.model.name, 'momentum2');
  });
  testWidgets('skipPersist()', (tester) async {
    var widget = asyncApp();
    await inject(tester, widget, milliseconds: 2000);
    var controller = widget.controllerForTest<AsyncTestController>();
    expect(await controller.skipPersist(), true);
  });
  testWidgets('listen(...) | sendEvent(...)', (tester) async {
    var widget = asyncApp(expect: expect);
    await inject(tester, widget, milliseconds: 3000);
    var controller = widget.controllerForTest<AsyncTestController>();
    controller.sendEvent('test');
    controller.sendEvent(AsyncEvent(117, 'test'));
  });
  testWidgets('addListener(...)', (tester) async {
    var widget = asyncApp(expect: expect);
    await inject(tester, widget, milliseconds: 3000);
    var controller = widget.controllerForTest<AsyncTestController>();
    controller.model.update(value: 100, name: 'momentum');
    controller.model.update(value: 101, name: 'momentum101');
    controller.backward();
  });
  testWidgets('backward()', (tester) async {
    var widget = asyncApp();
    await inject(tester, widget, milliseconds: 3000);
    var controller = widget.controllerForTest<AsyncTestController>();
    controller.model.update(value: 1, name: 'momentum1');
    controller.model.update(value: 2, name: 'momentum2');
    controller.model.update(value: 3, name: 'momentum3');
    controller.backward();
    expect(controller.model.value, 2);
    expect(controller.model.name, 'momentum2');
    controller.backward();
    expect(controller.model.value, 1);
    expect(controller.model.name, 'momentum1');
  });
  testWidgets('forward()', (tester) async {
    var widget = asyncApp();
    await inject(tester, widget, milliseconds: 3000);
    var controller = widget.controllerForTest<AsyncTestController>();
    controller.model.update(value: 1, name: 'momentum1');
    controller.model.update(value: 2, name: 'momentum2');
    controller.model.update(value: 3, name: 'momentum3');
    controller.backward();
    expect(controller.model.value, 2);
    expect(controller.model.name, 'momentum2');
    controller.backward();
    expect(controller.model.value, 1);
    expect(controller.model.name, 'momentum1');

    // forward phase
    controller.forward();
    expect(controller.model.value, 2);
    expect(controller.model.name, 'momentum2');
    controller.forward();
    expect(controller.model.value, 3);
    expect(controller.model.name, 'momentum3');
  });
  testWidgets('dependOn<T>()', (tester) async {
    var widget = asyncApp();
    await inject(tester, widget, milliseconds: 3000);
    var controller = widget.controllerForTest<AsyncTestController>();
    var dummyController = controller.dependOn<DummyController>();
    expect(dummyController is DummyController, true);
    try {
      controller.dependOn<CounterController>();
      controller.dependOn<AsyncTestController>();
    } on dynamic catch (e) {
      expect(e is Exception, true);
    }
  });
  testWidgets('getService<T>()', (tester) async {});
  testWidgets('reset()', (tester) async {});

  // property tests
  testWidgets('prevModel', (tester) async {});
  testWidgets('model', (tester) async {});
  testWidgets('nextModel', (tester) async {});
  testWidgets('isLazy', (tester) async {});
  testWidgets('persistenceKey', (tester) async {});
}
