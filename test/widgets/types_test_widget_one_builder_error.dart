import 'package:flutter/material.dart';
import 'package:momentum/momentum.dart';

import '../components/types-test/index.dart';

const keyTypesErrorIncrementButton = Key('keyTypeTestIncrementButton');
const keyTypesErrorDecrementButton = Key('keyTypeTestDecrementButton');
const keyTypesErrorMultiplyButton = Key('keyTypeTestMultiplyButton');
const keyTypesErrorDivideButton = Key('keyTypeTestDivideButton');
const keyTypeErrorToSquareButton = Key('keyTypeTestToSquareButton');

Momentum typesTestWidgetError() {
  return Momentum(
    child: _TypesTestErrorApp(),
    controllers: [
      ATypesTestCtrl()..config(maxTimeTravelSteps: 10),
      BTypesTestCtrl(),
      CTypesTestCtrl(),
      ImplementsABCTypesCtrl(),
    ],
  );
}

class _TypesTestErrorApp extends StatelessWidget {
  const _TypesTestErrorApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Counter App',
      home: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: _TypesTestErrorWidgets(),
          ),
        ),
      ),
    );
  }
}

class _TypesTestErrorWidgets extends StatelessWidget {
  const _TypesTestErrorWidgets({
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
        var abc = snapshot<ATypesTestModel>(); // throws an error
        return _TypesTestErrorContent(
          aTypeTest: aTypeTest,
          bTypeTest: bTypeTest,
          cTypeTest: cTypeTest,
          abcTypeTest: abc,
        );
      },
    );
  }
}

class _TypesTestErrorContent extends StatelessWidget {
  const _TypesTestErrorContent({
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
          key: keyTypesErrorIncrementButton,
          onPressed: () {
            Momentum.controller<ImplementsABCTypesCtrl>(
              context,
            ).increment();
          },
          child: Text('Increment'),
        ),
        FlatButton(
          key: keyTypesErrorDecrementButton,
          onPressed: () {
            Momentum.controller<ImplementsABCTypesCtrl>(
              context,
            ).decrement();
          },
          child: Text('Decrement'),
        ),
        FlatButton(
          key: keyTypesErrorMultiplyButton,
          onPressed: () {
            Momentum.controller<ImplementsABCTypesCtrl>(
              context,
            ).multiplyBy(2);
          },
          child: Text('Multiply by 2'),
        ),
        FlatButton(
          key: keyTypesErrorDivideButton,
          onPressed: () {
            Momentum.controller<ImplementsABCTypesCtrl>(
              context,
            ).divideBy(2);
          },
          child: Text('Divide by 2'),
        ),
        FlatButton(
          key: keyTypeErrorToSquareButton,
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
