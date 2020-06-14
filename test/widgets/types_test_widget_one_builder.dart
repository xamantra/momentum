import 'package:flutter/material.dart';
import 'package:momentum/momentum.dart';

import '../components/types-test/index.dart';

const keyTypeTestIncrementButton = Key('keyTypeTestIncrementButton');
const keyTypeTestDecrementButton = Key('keyTypeTestDecrementButton');
const keyTypeTestMultiplyButton = Key('keyTypeTestMultiplyButton');
const keyTypeTestDivideButton = Key('keyTypeTestDivideButton');
const keyTypeTestToSquareButton = Key('keyTypeTestToSquareButton');

Momentum typesTestWidgetOneBuilder() {
  return Momentum(
    child: _TypesTestOneBuilderApp(),
    controllers: [
      ATypesTestCtrl()..config(maxTimeTravelSteps: 10),
      BTypesTestCtrl(),
      CTypesTestCtrl(),
      ImplementsABCTypesCtrl(),
    ],
  );
}

class _TypesTestOneBuilderApp extends StatelessWidget {
  const _TypesTestOneBuilderApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Counter App',
      home: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: _TypesTestOneBuilderWidgets(),
          ),
        ),
      ),
    );
  }
}

class _TypesTestOneBuilderWidgets extends StatelessWidget {
  const _TypesTestOneBuilderWidgets({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MomentumBuilder(
      controllers: [
        ATypesTestCtrl,
        BTypesTestCtrl,
        CTypesTestCtrl,
        ImplementsABCTypesCtrl,
      ],
      builder: (context, snapshot) {
        var aTypeTest = snapshot<ATypesTestModel>(ATypesTestCtrl);
        var bTypeTest = snapshot<ATypesTestModel>(BTypesTestCtrl);
        var cTypeTest = snapshot<ATypesTestModel>(CTypesTestCtrl);
        var abc = snapshot<ATypesTestModel>(ImplementsABCTypesCtrl);
        return _TypesTestBuilderContent(
          aTypeTest: aTypeTest,
          bTypeTest: bTypeTest,
          cTypeTest: cTypeTest,
          abcTypeTest: abc,
        );
      },
    );
  }
}

class _TypesTestBuilderContent extends StatelessWidget {
  const _TypesTestBuilderContent({
    Key key,
    @required this.aTypeTest,
    @required this.bTypeTest,
    @required this.cTypeTest,
    @required this.abcTypeTest,
  }) : super(key: key);

  final ATypesTestModel aTypeTest;
  final ATypesTestModel bTypeTest;
  final ATypesTestModel cTypeTest;
  final ATypesTestModel abcTypeTest;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text('$ATypesTestCtrl: ${aTypeTest.value}'),
        Text('$BTypesTestCtrl: ${bTypeTest.value}'),
        Text('$CTypesTestCtrl.value: ${cTypeTest.value}'),
        Text('$CTypesTestCtrl.square: ${cTypeTest.square}'),
        Text('$ImplementsABCTypesCtrl.value: ${abcTypeTest.value}'),
        Text('$ImplementsABCTypesCtrl.square: ${abcTypeTest.square}'),
        FlatButton(
          key: keyTypeTestIncrementButton,
          onPressed: () {
            Momentum.controller<ImplementsABCTypesCtrl>(
              context,
            ).increment();
          },
          child: Text('Increment'),
        ),
        FlatButton(
          key: keyTypeTestDecrementButton,
          onPressed: () {
            Momentum.controller<ImplementsABCTypesCtrl>(
              context,
            ).decrement();
          },
          child: Text('Decrement'),
        ),
        FlatButton(
          key: keyTypeTestMultiplyButton,
          onPressed: () {
            Momentum.controller<ImplementsABCTypesCtrl>(
              context,
            ).multiplyBy(2);
          },
          child: Text('Multiply by 2'),
        ),
        FlatButton(
          key: keyTypeTestDivideButton,
          onPressed: () {
            Momentum.controller<ImplementsABCTypesCtrl>(
              context,
            ).divideBy(2);
          },
          child: Text('Divide by 2'),
        ),
        FlatButton(
          key: keyTypeTestToSquareButton,
          onPressed: () {
            Momentum.controller<ImplementsABCTypesCtrl>(
              context,
            ).square();
          },
          child: Text('To Square'),
        ),
      ],
    );
  }
}
