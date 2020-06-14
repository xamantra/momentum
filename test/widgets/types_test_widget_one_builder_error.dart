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
      ATypesTestController()..config(maxTimeTravelSteps: 10),
      BTypesTestController(),
      CTypesTestController(),
      ImplementsABCTypesController(),
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
        ATypesTestController,
        BTypesTestController,
        CTypesTestController,
        ImplementsABCTypesController,
      ],
      builder: (context, snapshot) {
        var aTypeTest = snapshot<TypesTestModel>(ATypesTestController);
        var bTypeTest = snapshot<TypesTestModel>(BTypesTestController);
        var cTypeTest = snapshot<TypesTestModel>(CTypesTestController);
        var abc = snapshot<TypesTestModel>(); // throws an error
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

  final TypesTestModel aTypeTest;
  final TypesTestModel bTypeTest;
  final TypesTestModel cTypeTest;
  final TypesTestModel abcTypeTest;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Text('$ATypesTestController: ${aTypeTest.value}'),
        Text('$BTypesTestController: ${bTypeTest.value}'),
        Text('$CTypesTestController.value: ${cTypeTest.value}'),
        Text('$CTypesTestController.square: ${cTypeTest.square}'),
        Text('$ImplementsABCTypesController.value: ${abcTypeTest.value}'),
        Text('$ImplementsABCTypesController.square: ${abcTypeTest.square}'),
        FlatButton(
          key: keyTypesErrorIncrementButton,
          onPressed: () {
            Momentum.controller<ImplementsABCTypesController>(
              context,
            ).increment();
          },
          child: Text('Increment'),
        ),
        FlatButton(
          key: keyTypesErrorDecrementButton,
          onPressed: () {
            Momentum.controller<ImplementsABCTypesController>(
              context,
            ).decrement();
          },
          child: Text('Decrement'),
        ),
        FlatButton(
          key: keyTypesErrorMultiplyButton,
          onPressed: () {
            Momentum.controller<ImplementsABCTypesController>(
              context,
            ).multiplyBy(2);
          },
          child: Text('Multiply by 2'),
        ),
        FlatButton(
          key: keyTypesErrorDivideButton,
          onPressed: () {
            Momentum.controller<ImplementsABCTypesController>(
              context,
            ).divideBy(2);
          },
          child: Text('Divide by 2'),
        ),
        FlatButton(
          key: keyTypeErrorToSquareButton,
          onPressed: () {
            Momentum.controller<ImplementsABCTypesController>(
              context,
            ).square();
          },
          child: Text('To Square'),
        ),
      ],
    );
  }
}
