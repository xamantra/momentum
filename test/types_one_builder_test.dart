import 'package:flutter_test/flutter_test.dart';

import 'components/types-test/index.dart';
import 'utilities/launcher.dart';
import 'widgets/types_test_widget_one_builder.dart';

void main() {
  testWidgets(
    'testObjectRuntimeType',
    testObjectRuntimeType,
  );

  testWidgets(
    'testGenericTypeParam: <T>',
    testGenericTypeParam,
  );

  testWidgets(
    'CTypesTestController extends BTypesTestController',
    testCTypeTestController,
  );

  testWidgets(
    'all: ImplementsABCTypesController',
    testImplementsABCTypeController,
  );
}

Future<void> testObjectRuntimeType(WidgetTester tester) async {
  var widget = typesTestWidgetOneBuilder();
  await launch(tester, widget);

  /* ATypesTestController */
  var aTypesTestController = widget.controllerOfType<ATypesTestController>(
    ATypesTestController,
  );
  expect(aTypesTestController, isInstanceOf<ATypesTestController>());
  aTypesTestController.increment();
  await tester.pumpAndSettle();
  expect(find.text('$ATypesTestController: 1'), findsOneWidget);
  aTypesTestController.increment();
  await tester.pumpAndSettle();
  expect(find.text('$ATypesTestController: 2'), findsOneWidget);
  aTypesTestController.increment();
  await tester.pumpAndSettle();
  expect(find.text('$ATypesTestController: 3'), findsOneWidget);
  aTypesTestController.multiplyBy(5);
  await tester.pumpAndSettle();
  expect(find.text('$ATypesTestController: 15'), findsOneWidget);
  expect(aTypesTestController.isOdd(), true); // the mixin method
  /* ATypesTestController */

  /* BTypesTestController */
  var bTypesTestController = widget.controllerOfType<BTypesTestController>(
    BTypesTestController,
  );
  expect(bTypesTestController, isInstanceOf<BTypesTestController>());
  bTypesTestController.increment();
  await tester.pumpAndSettle();
  expect(find.text('$BTypesTestController: 1'), findsOneWidget);
  // verify A controller that it didn't update/rebuild.
  expect(find.text('$ATypesTestController: 15'), findsOneWidget);
  bTypesTestController.increment();
  await tester.pumpAndSettle();
  expect(find.text('$BTypesTestController: 2'), findsOneWidget);
  bTypesTestController.divideBy(2);
  await tester.pumpAndSettle();
  expect(bTypesTestController.isOdd(), true); // the mixin method
  expect(find.text('$BTypesTestController: 1'), findsOneWidget);
  bTypesTestController.increment();
  await tester.pumpAndSettle();
  expect(find.text('$BTypesTestController: 2'), findsOneWidget);
  expect(bTypesTestController.isOdd(), false); // the mixin method
  /* BTypesTestController */

  /* TypesTestMixinController */
  // ignore: lines_longer_than_80_chars
  var typesTestMixinController = widget.controllerOfType<TypesTestMixinController>(
    TypesTestMixinController,
  );
  // should be null because in typeTestWidget(),
  // there is no controller instance of type TypesTestMixinController(),
  // well you can't instantiate a mixin.
  expect(typesTestMixinController, null);
  /* TypesTestMixinController */

  /* TypesTestController */
  var typesTestController = widget.controllerOfType<TypesTestController>(
    TypesTestController,
  );
  // should be null because in typeTestWidget(),
  // there is no controller instance of type TypesTestController(),
  // well you can't instantiate an abstract class.
  // TypesTestController is not "BTypesTestController"
  // TypesTestController is not "ATypesTestController"
  expect(typesTestController, null);
  /* TypesTestController */
}

Future<void> testGenericTypeParam(WidgetTester tester) async {
  var widget = typesTestWidgetOneBuilder();
  await launch(tester, widget);

  /* ATypesTestController */
  var aTypesTestController = widget.controllerForTest<ATypesTestController>();
  expect(aTypesTestController, isInstanceOf<ATypesTestController>());
  aTypesTestController.increment();
  await tester.pumpAndSettle();
  expect(find.text('$ATypesTestController: 1'), findsOneWidget);
  aTypesTestController.increment();
  await tester.pumpAndSettle();
  expect(find.text('$ATypesTestController: 2'), findsOneWidget);
  aTypesTestController.increment();
  await tester.pumpAndSettle();
  expect(find.text('$ATypesTestController: 3'), findsOneWidget);
  aTypesTestController.multiplyBy(5);
  await tester.pumpAndSettle();
  expect(find.text('$ATypesTestController: 15'), findsOneWidget);
  expect(aTypesTestController.isOdd(), true); // the mixin method
  /* ATypesTestController */

  /* BTypesTestController */
  var bTypesTestBController = widget.controllerForTest<BTypesTestController>();
  expect(bTypesTestBController, isInstanceOf<BTypesTestController>());
  bTypesTestBController.increment();
  await tester.pumpAndSettle();
  expect(find.text('$BTypesTestController: 1'), findsOneWidget);
  // verify A controller that it didn't update/rebuild.
  expect(find.text('$ATypesTestController: 15'), findsOneWidget);
  bTypesTestBController.increment();
  await tester.pumpAndSettle();
  expect(find.text('$BTypesTestController: 2'), findsOneWidget);
  bTypesTestBController.divideBy(2);
  await tester.pumpAndSettle();
  expect(bTypesTestBController.isOdd(), true); // the mixin method
  expect(find.text('$BTypesTestController: 1'), findsOneWidget);
  bTypesTestBController.increment();
  await tester.pumpAndSettle();
  expect(find.text('$BTypesTestController: 2'), findsOneWidget);
  expect(bTypesTestBController.isOdd(), false); // the mixin method
  /* BTypesTestController */

  /* TypesTestMixinController */
  // ignore: lines_longer_than_80_chars
  var typesTestMixinController = widget.controllerForTest<TypesTestMixinController>();
  // should be null because in typeTestWidget(),
  // there is no controller instance of type TypesTestMixinController(),
  // well you can't instantiate a mixin.
  expect(typesTestMixinController, null);
  /* TypesTestMixinController */

  /* TypesTestController */
  var typesTestController = widget.controllerForTest<TypesTestController>();
  // should be null because in typeTestWidget(),
  // there is no controller instance of type TypesTestController(),
  // well you can't instantiate an abstract class.
  // TypesTestController is not "BTypesTestController"
  // TypesTestController is not "ATypesTestController"
  expect(typesTestController, null);
  /* TypesTestController */
}

Future<void> testCTypeTestController(WidgetTester tester) async {
  var widget = typesTestWidgetOneBuilder();
  await launch(tester, widget);

  /* BTypesTestController */
  var bTypesTestBController = widget.controllerForTest<BTypesTestController>();
  expect(bTypesTestBController, isInstanceOf<BTypesTestController>());
  bTypesTestBController.decrement();
  await tester.pumpAndSettle();
  expect(find.text('$BTypesTestController: -1'), findsOneWidget);
  bTypesTestBController.increment();
  await tester.pumpAndSettle();
  expect(find.text('$BTypesTestController: 0'), findsOneWidget);
  bTypesTestBController.increment();
  await tester.pumpAndSettle();
  expect(find.text('$BTypesTestController: 1'), findsOneWidget);
  bTypesTestBController.increment();
  await tester.pumpAndSettle();
  expect(find.text('$BTypesTestController: 2'), findsOneWidget);
  bTypesTestBController.divideBy(2);
  await tester.pumpAndSettle();
  expect(bTypesTestBController.isOdd(), true); // the mixin method
  expect(find.text('$BTypesTestController: 1'), findsOneWidget);
  bTypesTestBController.increment();
  await tester.pumpAndSettle();
  expect(find.text('$BTypesTestController: 2'), findsOneWidget);
  expect(bTypesTestBController.isOdd(), false); // the mixin method
  /* BTypesTestController */

  /* CTypesTestController */
  var cTypesTestController = widget.controllerForTest<CTypesTestController>();
  expect(cTypesTestController, isInstanceOf<CTypesTestController>());
  expect(find.text('$CTypesTestController.value: 0'), findsOneWidget);
  cTypesTestController.increment();
  await tester.pumpAndSettle();
  expect(find.text('$CTypesTestController.value: 1'), findsOneWidget);
  // verify B controller that it didn't update/rebuild.
  expect(find.text('$BTypesTestController: 2'), findsOneWidget);
  cTypesTestController.increment();
  await tester.pumpAndSettle();
  expect(find.text('$CTypesTestController.value: 2'), findsOneWidget);
  cTypesTestController.increment();
  await tester.pumpAndSettle();
  expect(find.text('$CTypesTestController.value: 3'), findsOneWidget);
  cTypesTestController.increment();
  await tester.pumpAndSettle();
  expect(find.text('$CTypesTestController.value: 4'), findsOneWidget);
  cTypesTestController.square();
  await tester.pumpAndSettle();
  expect(find.text('$CTypesTestController.square: 2'), findsOneWidget);
  /* CTypesTestController */
}

Future<void> testImplementsABCTypeController(WidgetTester tester) async {
  var widget = typesTestWidgetOneBuilder();
  await launch(tester, widget);

  /* ATypesTestController */
  var aTypesTestController = widget.controllerOfType<ATypesTestController>(
    ATypesTestController,
  );
  expect(aTypesTestController, isInstanceOf<ATypesTestController>());
  aTypesTestController.increment();
  await tester.pumpAndSettle();
  expect(find.text('$ATypesTestController: 1'), findsOneWidget);
  aTypesTestController.increment();
  await tester.pumpAndSettle();
  expect(find.text('$ATypesTestController: 2'), findsOneWidget);
  aTypesTestController.backward(); // undo
  await tester.pumpAndSettle();
  expect(find.text('$ATypesTestController: 1'), findsOneWidget);
  aTypesTestController.multiplyBy(5);
  await tester.pumpAndSettle();
  expect(find.text('$ATypesTestController: 5'), findsOneWidget);
  expect(aTypesTestController.isOdd(), true); // the mixin method
  /* ATypesTestController */

  /* BTypesTestController */
  var bTypesTestController = widget.controllerOfType<BTypesTestController>(
    BTypesTestController,
  );
  expect(bTypesTestController, isInstanceOf<BTypesTestController>());
  bTypesTestController.increment();
  await tester.pumpAndSettle();
  expect(find.text('$BTypesTestController: 1'), findsOneWidget);
  // verify A controller that it didn't update/rebuild.
  expect(find.text('$ATypesTestController: 5'), findsOneWidget);
  // undo, but no effect because B's undo/redo is disabled.
  bTypesTestController.backward();
  await tester.pumpAndSettle();
  expect(find.text('$BTypesTestController: 1'), findsOneWidget);
  bTypesTestController.increment();
  await tester.pumpAndSettle();
  expect(bTypesTestController.isOdd(), false); // the mixin method
  expect(find.text('$BTypesTestController: 2'), findsOneWidget);
  bTypesTestController.increment();
  await tester.pumpAndSettle();
  expect(find.text('$BTypesTestController: 3'), findsOneWidget);
  expect(bTypesTestController.isOdd(), true); // the mixin method
  /* BTypesTestController */

  /* CTypesTestController */
  var cTypesTestController = widget.controllerForTest<CTypesTestController>();
  expect(cTypesTestController, isInstanceOf<CTypesTestController>());
  expect(find.text('$CTypesTestController.value: 0'), findsOneWidget);
  cTypesTestController.increment();
  await tester.pumpAndSettle();
  expect(find.text('$CTypesTestController.value: 1'), findsOneWidget);
  // verify B controller that it didn't update/rebuild.
  expect(find.text('$BTypesTestController: 3'), findsOneWidget);
  cTypesTestController.increment();
  await tester.pumpAndSettle();
  expect(find.text('$CTypesTestController.value: 2'), findsOneWidget);
  cTypesTestController.increment();
  await tester.pumpAndSettle();
  expect(find.text('$CTypesTestController.value: 3'), findsOneWidget);
  cTypesTestController.increment();
  await tester.pumpAndSettle();
  expect(find.text('$CTypesTestController.value: 4'), findsOneWidget);
  cTypesTestController.square();
  await tester.pumpAndSettle();
  expect(find.text('$CTypesTestController.square: 2'), findsOneWidget);
  cTypesTestController.add(10);
  await tester.pumpAndSettle();
  expect(find.text('$CTypesTestController.value: 14'), findsOneWidget);
  /* CTypesTestController */

  /* ImplementsABCTypesController */
  var abcController = widget.controllerForTest<ImplementsABCTypesController>();
  expect(abcController, isInstanceOf<ImplementsABCTypesController>());
  expect(find.text('$ImplementsABCTypesController.value: 10'), findsOneWidget);
  expect(find.text('$ImplementsABCTypesController.square: 4'), findsOneWidget);
  await tester.tap(find.byKey(keyTypeTestIncrementButton));
  await tester.pumpAndSettle();
  expect(find.text('$ImplementsABCTypesController.value: 11'), findsOneWidget);
  await tester.tap(find.byKey(keyTypeTestDecrementButton));
  await tester.pumpAndSettle();
  expect(find.text('$ImplementsABCTypesController.value: 10'), findsOneWidget);
  await tester.tap(find.byKey(keyTypeTestMultiplyButton));
  await tester.pumpAndSettle();
  expect(find.text('$ImplementsABCTypesController.value: 20'), findsOneWidget);
  await tester.tap(find.byKey(keyTypeTestDivideButton));
  await tester.pumpAndSettle();
  expect(find.text('$ImplementsABCTypesController.value: 10'), findsOneWidget);
  // verify A controller that it didn't update/rebuild.
  expect(find.text('$ATypesTestController: 5'), findsOneWidget);
  // verify B controller that it didn't update/rebuild.
  expect(find.text('$BTypesTestController: 3'), findsOneWidget);
  // verify C controller that it didn't update/rebuild.
  expect(find.text('$CTypesTestController.value: 14'), findsOneWidget);
  abcController.add(15);
  await tester.pumpAndSettle();
  expect(find.text('$ImplementsABCTypesController.value: 25'), findsOneWidget);
  abcController.square();
  await tester.pumpAndSettle();
  expect(find.text('$ImplementsABCTypesController.square: 5'), findsOneWidget);
  /* ImplementsABCTypesController */
}
