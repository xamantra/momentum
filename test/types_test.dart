import 'package:flutter_test/flutter_test.dart';

import 'components/type-test/type-test.controller.dart';
import 'utilities/launcher.dart';
import 'widgets/type_test_widget.dart';

void main() {
  testWidgets('Test runtime type checks', (tester) async {
    var widget = typeTestWidget();
    await launch(tester, widget);

    /* TypeTestAController */
    var aTypeTestController = widget.controllerOfType<ATypeTestController>(
      ATypeTestController,
    );
    expect(aTypeTestController, isInstanceOf<ATypeTestController>());
    aTypeTestController.increment();
    await tester.pumpAndSettle();
    expect(find.text('$ATypeTestController: 1'), findsOneWidget);
    aTypeTestController.increment();
    await tester.pumpAndSettle();
    expect(find.text('$ATypeTestController: 2'), findsOneWidget);
    aTypeTestController.increment();
    await tester.pumpAndSettle();
    expect(find.text('$ATypeTestController: 3'), findsOneWidget);
    aTypeTestController.multiplyBy(5);
    await tester.pumpAndSettle();
    expect(find.text('$ATypeTestController: 15'), findsOneWidget);
    expect(aTypeTestController.isOdd(), true); // the mixin method
    /* TypeTestAController */

    /* TypeTestBController */
    var bTypeTestController = widget.controllerOfType<BTypeTestController>(
      BTypeTestController,
    );
    expect(bTypeTestController, isInstanceOf<BTypeTestController>());
    bTypeTestController.increment();
    await tester.pumpAndSettle();
    expect(find.text('$BTypeTestController: 1'), findsOneWidget);
    // verify A controller that it didn't update/rebuild.
    expect(find.text('$ATypeTestController: 15'), findsOneWidget);
    bTypeTestController.increment();
    await tester.pumpAndSettle();
    expect(find.text('$BTypeTestController: 2'), findsOneWidget);
    bTypeTestController.divideBy(2);
    await tester.pumpAndSettle();
    expect(bTypeTestController.isOdd(), true); // the mixin method
    expect(find.text('$BTypeTestController: 1'), findsOneWidget);
    bTypeTestController.increment();
    await tester.pumpAndSettle();
    expect(find.text('$BTypeTestController: 2'), findsOneWidget);
    expect(bTypeTestController.isOdd(), false); // the mixin method
    /* TypeTestBController */

    /* TypeTestMixinController */
    // ignore: lines_longer_than_80_chars
    var typeTestMixinController = widget.controllerOfType<TypeTestMixinController>(
      TypeTestMixinController,
    );
    // should be null because in typeTestWidget(),
    // there is no controller instance of type TypeTestMixinController(),
    // well you can't instantiate a mixin.
    expect(typeTestMixinController, null);
    /* TypeTestMixinController */

    /* TypeTestController */
    var typeTestController = widget.controllerOfType<TypeTestController>(
      TypeTestController,
    );
    // should be null because in typeTestWidget(),
    // there is no controller instance of type TypeTestController(),
    // well you can't instantiate an abstract class.
    // TypeTestController is not "TypeTestBController"
    // TypeTestController is not "TypeTestAController"
    expect(typeTestController, null);
    /* TypeTestController */
  });

  testWidgets('Test generic param <T> type checks', (tester) async {
    var widget = typeTestWidget();
    await launch(tester, widget);

    /* TypeTestAController */
    var aTypeTestController = widget.controllerForTest<ATypeTestController>();
    expect(aTypeTestController, isInstanceOf<ATypeTestController>());
    aTypeTestController.increment();
    await tester.pumpAndSettle();
    expect(find.text('$ATypeTestController: 1'), findsOneWidget);
    aTypeTestController.increment();
    await tester.pumpAndSettle();
    expect(find.text('$ATypeTestController: 2'), findsOneWidget);
    aTypeTestController.increment();
    await tester.pumpAndSettle();
    expect(find.text('$ATypeTestController: 3'), findsOneWidget);
    aTypeTestController.multiplyBy(5);
    await tester.pumpAndSettle();
    expect(find.text('$ATypeTestController: 15'), findsOneWidget);
    expect(aTypeTestController.isOdd(), true); // the mixin method
    /* TypeTestAController */

    /* TypeTestBController */
    var bTypeTestBController = widget.controllerForTest<BTypeTestController>();
    expect(bTypeTestBController, isInstanceOf<BTypeTestController>());
    bTypeTestBController.increment();
    await tester.pumpAndSettle();
    expect(find.text('$BTypeTestController: 1'), findsOneWidget);
    // verify A controller that it didn't update/rebuild.
    expect(find.text('$ATypeTestController: 15'), findsOneWidget);
    bTypeTestBController.increment();
    await tester.pumpAndSettle();
    expect(find.text('$BTypeTestController: 2'), findsOneWidget);
    bTypeTestBController.divideBy(2);
    await tester.pumpAndSettle();
    expect(bTypeTestBController.isOdd(), true); // the mixin method
    expect(find.text('$BTypeTestController: 1'), findsOneWidget);
    bTypeTestBController.increment();
    await tester.pumpAndSettle();
    expect(find.text('$BTypeTestController: 2'), findsOneWidget);
    expect(bTypeTestBController.isOdd(), false); // the mixin method
    /* TypeTestBController */

    /* TypeTestMixinController */
    // ignore: lines_longer_than_80_chars
    var typeTestMixinController = widget.controllerForTest<TypeTestMixinController>();
    // should be null because in typeTestWidget(),
    // there is no controller instance of type TypeTestMixinController(),
    // well you can't instantiate a mixin.
    expect(typeTestMixinController, null);
    /* TypeTestMixinController */

    /* TypeTestController */
    var typeTestController = widget.controllerForTest<TypeTestController>();
    // should be null because in typeTestWidget(),
    // there is no controller instance of type TypeTestController(),
    // well you can't instantiate an abstract class.
    // TypeTestController is not "TypeTestBController"
    // TypeTestController is not "TypeTestAController"
    expect(typeTestController, null);
    /* TypeTestController */
  });

  testWidgets('CTypeTestController ext BTypeTestController', (tester) async {
    var widget = typeTestWidget();
    await launch(tester, widget);

    /* TypeTestBController */
    var bTypeTestBController = widget.controllerForTest<BTypeTestController>();
    expect(bTypeTestBController, isInstanceOf<BTypeTestController>());
    bTypeTestBController.decrement();
    await tester.pumpAndSettle();
    expect(find.text('$BTypeTestController: -1'), findsOneWidget);
    bTypeTestBController.increment();
    await tester.pumpAndSettle();
    expect(find.text('$BTypeTestController: 0'), findsOneWidget);
    bTypeTestBController.increment();
    await tester.pumpAndSettle();
    expect(find.text('$BTypeTestController: 1'), findsOneWidget);
    bTypeTestBController.increment();
    await tester.pumpAndSettle();
    expect(find.text('$BTypeTestController: 2'), findsOneWidget);
    bTypeTestBController.divideBy(2);
    await tester.pumpAndSettle();
    expect(bTypeTestBController.isOdd(), true); // the mixin method
    expect(find.text('$BTypeTestController: 1'), findsOneWidget);
    bTypeTestBController.increment();
    await tester.pumpAndSettle();
    expect(find.text('$BTypeTestController: 2'), findsOneWidget);
    expect(bTypeTestBController.isOdd(), false); // the mixin method
    /* TypeTestBController */

    /* CTypeTestController */
    var cTypeTestController = widget.controllerForTest<CTypeTestController>();
    expect(cTypeTestController, isInstanceOf<CTypeTestController>());
    expect(find.text('$CTypeTestController.value: 0'), findsOneWidget);
    cTypeTestController.increment();
    await tester.pumpAndSettle();
    expect(find.text('$CTypeTestController.value: 1'), findsOneWidget);
    // verify B controller that it didn't update/rebuild.
    expect(find.text('$BTypeTestController: 2'), findsOneWidget);
    cTypeTestController.increment();
    await tester.pumpAndSettle();
    expect(find.text('$CTypeTestController.value: 2'), findsOneWidget);
    cTypeTestController.increment();
    await tester.pumpAndSettle();
    expect(find.text('$CTypeTestController.value: 3'), findsOneWidget);
    cTypeTestController.increment();
    await tester.pumpAndSettle();
    expect(find.text('$CTypeTestController.value: 4'), findsOneWidget);
    cTypeTestController.square();
    await tester.pumpAndSettle();
    expect(find.text('$CTypeTestController.square: 2'), findsOneWidget);
    /* CTypeTestController */
  });
}
