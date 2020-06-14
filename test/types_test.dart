import 'package:flutter_test/flutter_test.dart';

import 'components/type-test/type-test.controller.dart';
import 'utilities/launcher.dart';
import 'widgets/type_test_widget.dart';

void main() {
  testWidgets('Test runtime type checks', (tester) async {
    var widget = typeTestWidget();
    await launch(tester, widget);

    /* TypeTestAController */
    var typeTestAController = widget.controllerOfType<TypeTestAController>(
      TypeTestAController,
    );
    expect(typeTestAController, isInstanceOf<TypeTestAController>());
    typeTestAController.increment();
    await tester.pumpAndSettle();
    expect(find.text('$TypeTestAController: 1'), findsOneWidget);
    typeTestAController.increment();
    await tester.pumpAndSettle();
    expect(find.text('$TypeTestAController: 2'), findsOneWidget);
    typeTestAController.increment();
    await tester.pumpAndSettle();
    expect(find.text('$TypeTestAController: 3'), findsOneWidget);
    typeTestAController.multiplyBy(5);
    await tester.pumpAndSettle();
    expect(find.text('$TypeTestAController: 15'), findsOneWidget);
    expect(typeTestAController.isOdd(), true); // the mixin method
    /* TypeTestAController */

    /* TypeTestBController */
    var typeTestBController = widget.controllerOfType<TypeTestBController>(
      TypeTestBController,
    );
    expect(typeTestBController, isInstanceOf<TypeTestBController>());
    typeTestBController.increment();
    await tester.pumpAndSettle();
    expect(find.text('$TypeTestBController: 1'), findsOneWidget);
    typeTestBController.increment();
    await tester.pumpAndSettle();
    expect(find.text('$TypeTestBController: 2'), findsOneWidget);
    typeTestBController.divideBy(2);
    await tester.pumpAndSettle();
    expect(typeTestBController.isOdd(), true); // the mixin method
    expect(find.text('$TypeTestBController: 1'), findsOneWidget);
    typeTestBController.increment();
    await tester.pumpAndSettle();
    expect(find.text('$TypeTestBController: 2'), findsOneWidget);
    expect(typeTestBController.isOdd(), false); // the mixin method
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
}
