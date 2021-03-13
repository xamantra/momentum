import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/momentum.dart';
import 'package:momentum/src/momentum_error.dart';

import '../../demo_app/components/basic-list-example/index.dart';
import '../../demo_app/components/todo-example/index.dart';

void main() {
  testWidgets('test multiple controllers using one model in MomentumBuilder (with error)', (tester) async {
    var basicCtrl = BasicListExampleController();
    var basicCtrlExt = BasicListExtendedController();
    await tester.pumpWidget(
      Momentum(
        child: MaterialApp(
          home: Scaffold(
            body: MomentumBuilder(
              controllers: [
                BasicListExampleController,
                BasicListExtendedController,
              ],
              builder: (context, snapshot) {
                var basicModel = snapshot<BasicListExampleModel>();
                return Text(basicModel.list.length.toString());
              },
            ),
          ),
        ),
        controllers: [basicCtrl, basicCtrlExt],
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isInstanceOf<MomentumError>());
  });

  testWidgets('test multiple controllers using one model in MomentumBuilder', (tester) async {
    var basicCtrl = BasicListExampleController();
    var basicCtrlExt = BasicListExtendedController();
    await tester.pumpWidget(
      Momentum(
        child: MaterialApp(
          home: Scaffold(
            body: MomentumBuilder(
              controllers: [
                BasicListExampleController,
                BasicListExtendedController,
              ],
              builder: (context, snapshot) {
                var basicModel = snapshot<BasicListExampleModel>(BasicListExampleController);
                return Text(basicModel.list.length.toString());
              },
            ),
          ),
        ),
        controllers: [basicCtrl, basicCtrlExt],
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), null);

    var text = find.byType(Text);
    expect(text, findsOneWidget);
  });

  testWidgets('test missing controller in MomentumBuilder', (tester) async {
    var basicCtrl = BasicListExampleController();
    await tester.pumpWidget(
      Momentum(
        child: MaterialApp(
          home: Scaffold(
            body: MomentumBuilder(
              controllers: [],
              builder: (context, snapshot) {
                var basicModel = snapshot<BasicListExampleModel>();
                return Text(basicModel.list.length.toString());
              },
            ),
          ),
        ),
        controllers: [basicCtrl],
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isInstanceOf<MomentumError>());
  });

  testWidgets('test missing controller in MomentumBuilder from `dontRebuildIf`', (tester) async {
    var todoCtrl = TodoExampleController();
    await tester.pumpWidget(
      Momentum(
        child: MaterialApp(
          home: Scaffold(
            body: MomentumBuilder(
              controllers: [TodoExampleController],
              dontRebuildIf: (controller, _) {
                try {
                  controller<BasicListExampleController>();
                } catch (e) {
                  expect(e, isInstanceOf<MomentumError>());
                }
                return false;
              },
              builder: (context, snapshot) {
                return Text('text');
              },
            ),
          ),
        ),
        controllers: [todoCtrl],
      ),
    );
    await tester.pumpAndSettle();

    todoCtrl.addTodo('item 1');
    await tester.pumpAndSettle();
  });
}
