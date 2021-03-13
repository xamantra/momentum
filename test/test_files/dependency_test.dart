import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/momentum.dart';
import 'package:momentum/src/momentum_error.dart';

import '../demo_app/components/basic-list-example/index.dart';
import '../demo_app/components/calculator-example/index.dart';
import '../demo_app/components/todo-example/index.dart';
import '../demo_app/services/api-service.dart';
import '../demo_app/services/index.dart';
import 'utils.dart';

void main() {
  test('test controllers depedency with errors test', () async {
    var tester = MomentumTester(Momentum(controllers: [
      BasicListExampleController()..config(maxTimeTravelSteps: 100),
      TodoExampleController(),
    ]));
    await tester.init();

    var basicListController = tester.controller<BasicListExampleController>();
    isControllerValid<BasicListExampleController>(basicListController);
    isModelValid<BasicListExampleModel>(basicListController.model);

    var todoController = basicListController.controller<TodoExampleController>();
    isControllerValid<TodoExampleController>(todoController);
    isModelValid<TodoExampleModel>(todoController.model);

    // test errors
    try {
      basicListController.controller<BasicListExampleController>();
    } catch (e) {
      expect(e, isInstanceOf<MomentumError>());
    }

    try {
      basicListController.controller<CalculatorExampleController>();
    } catch (e) {
      expect(e, isInstanceOf<MomentumError>());
    }
  });

  testWidgets('test controllers depedency: manage other controllers from other controller', (tester) async {
    var basicListCtrl = BasicListExampleController()..config(maxTimeTravelSteps: 100);
    var todoCtrl = TodoExampleController();
    await tester.pumpWidget(
      Momentum(
        child: MaterialApp(home: Scaffold()),
        controllers: [basicListCtrl, todoCtrl],
      ),
    );
    await tester.pumpAndSettle();

    todoCtrl.addOnBasicList('Item 1');
    expect(basicListCtrl.model.list.last, 'Item 1');

    todoCtrl.addOnBasicList('Item 5');
    expect(basicListCtrl.model.list.last, 'Item 5');

    basicListCtrl.backward(); // undo
    expect(basicListCtrl.model.list.last, 'Item 1'); // current
    expect(basicListCtrl.prevModel.list, const []); // previous
    expect(basicListCtrl.nextModel.list.last, 'Item 5'); // next -> controller.forward()
    basicListCtrl.forward(); // redo
    expect(basicListCtrl.model.list.last, 'Item 5');
  });

  testWidgets('test services depedency from a controller', (tester) async {
    var basicListCtrl = BasicListExampleController();
    await tester.pumpWidget(
      Momentum(
        child: MaterialApp(home: Scaffold()),
        controllers: [basicListCtrl],
        services: [BasicListService()],
      ),
    );
    await tester.pumpAndSettle();

    basicListCtrl.addFromService('Jane', '21');
    expect(basicListCtrl.model.list.last, 'Jane - 21');

    basicListCtrl.addFromService('John', '00');
    expect(basicListCtrl.model.list.last, 'John - 00');
  });

  test('test controllers->services depedency', () async {
    var tester = MomentumTester(
      Momentum(
        controllers: [
          BasicListExampleController()..config(maxTimeTravelSteps: 100),
          TodoExampleController(),
        ],
        services: [ApiService()],
        enableLogging: true,
      ),
    );
    await tester.init();

    var basicListController = tester.controller<BasicListExampleController>();
    isControllerValid<BasicListExampleController>(basicListController);
    isModelValid<BasicListExampleModel>(basicListController.model);

    var api = basicListController.service<ApiService>();
    expect(api, isInstanceOf<ApiService>());

    // test errors
    try {
      basicListController.service<DummyService>();
    } catch (e) {
      expect(e, isInstanceOf<MomentumError>());
    }
  });

  testWidgets('test services depedency from a another service', (tester) async {
    var basicSrv = BasicListService();
    var dummy = DummyService();
    await tester.pumpWidget(
      Momentum(
        child: MaterialApp(home: Scaffold()),
        controllers: [],
        services: [basicSrv, dummy],
      ),
    );
    await tester.pumpAndSettle();

    var getDummy = basicSrv.service<DummyService>();
    // must be the same instance
    expect(dummy, getDummy);
    expect(dummy == getDummy, true);

    var getBasicSrv = dummy.service<BasicListService>();
    // must be the same instance
    expect(basicSrv, getBasicSrv);
    expect(basicSrv == getBasicSrv, true);
  });

  test('test services depedency from a another service (unit version)', () async {
    var basicSrv = BasicListService();
    var dummy = DummyService();
    var tester = MomentumTester(Momentum(
      controllers: [],
      services: [basicSrv, dummy],
    ));
    await tester.init();

    var getDummy = basicSrv.service<DummyService>();
    // must be the same instance
    expect(dummy, getDummy);
    expect(dummy == getDummy, true);

    var getBasicSrv = dummy.service<BasicListService>();
    // must be the same instance
    expect(basicSrv, getBasicSrv);
    expect(basicSrv == getBasicSrv, true);
  });
}
