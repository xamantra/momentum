import 'package:flutter_test/flutter_test.dart';

import 'components/counter/index.dart';
import 'components/persist-test/persist-test.controller.dart';
import 'utilities/launcher.dart';
import 'widgets/counter.dart';
import 'widgets/persistence.dart';

void main() {
  testWidgets('Initialize Model', (tester) async {
    var widget = counter();
    await launch(tester, widget, milliseconds: 2000);
    var controller = widget.getController<CounterController>();
    expect(controller.model == null, false);
    expect(controller.model.value, 0);
  });

  testWidgets('controllerName', (tester) async {
    var widget = counter();
    await launch(tester, widget, milliseconds: 2000);
    var controller = widget.getController<CounterController>();
    expect(controller.model.controllerName, 'CounterController');
  });

  group('fromJson(...)', () {
    testWidgets('unimplemented', (tester) async {
      var widget = counter();
      await launch(tester, widget, milliseconds: 4000);
      var controller = widget.getController<CounterController>();
      var model = controller.model.fromJson({});
      expect(model == null, true);
    });

    testWidgets('implemented', (tester) async {
      var widget = persistedApp();
      await launch(tester, widget, milliseconds: 4000);
      var controller = widget.getController<PersistTestController>();
      var model = controller.model.fromJson({
        "username": "momentum",
        "email": "state@momentum",
      });
      expect(model.username, "momentum");
      expect(model.email, "state@momentum");
    });
  });

  group('toJson()', () {
    testWidgets('unimplemented', (tester) async {
      var widget = counter();
      await launch(tester, widget, milliseconds: 4000);
      var controller = widget.getController<CounterController>();
      var json = controller.model.toJson();
      expect(json == null, true);
    });

    testWidgets('implemented', (tester) async {
      var widget = persistedApp();
      await launch(tester, widget, milliseconds: 4000);
      var controller = widget.getController<PersistTestController>();
      var map = {
        "username": "momentum",
        "email": "state@momentum",
      };
      var model = controller.model.fromJson(map);
      expect(model.username, "momentum");
      expect(model.email, "state@momentum");
      var json = model.toJson();
      expect(json, map);
    });
  });
}
