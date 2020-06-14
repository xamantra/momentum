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
      ATypesTestController()..config(maxTimeTravelSteps: 10),
      BTypesTestController(),
      CTypesTestController(),
      ImplementsABCTypesController(),
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
        ATypesTestController,
        BTypesTestController,
        CTypesTestController,
        ImplementsABCTypesController,
      ],
      builder: (context, snapshot) {
        var aTypeTest = snapshot<TypesTestModel>(ATypesTestController);
        var bTypeTest = snapshot<TypesTestModel>(BTypesTestController);
        var cTypeTest = snapshot<TypesTestModel>(CTypesTestController);
        var abc = snapshot<TypesTestModel>(ImplementsABCTypesController);
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
        Text('$CTypesTestController.square: ${cTypeTest.squareRoot}'),
        Text('$ImplementsABCTypesController.value: ${abcTypeTest.value}'),
        Text('$ImplementsABCTypesController.square: ${abcTypeTest.squareRoot}'),
        FlatButton(
          key: keyTypeTestIncrementButton,
          onPressed: () {
            Momentum.controller<ImplementsABCTypesController>(
              context,
            ).increment();
          },
          child: Text('Increment'),
        ),
        FlatButton(
          key: keyTypeTestDecrementButton,
          onPressed: () {
            Momentum.controller<ImplementsABCTypesController>(
              context,
            ).decrement();
          },
          child: Text('Decrement'),
        ),
        FlatButton(
          key: keyTypeTestMultiplyButton,
          onPressed: () {
            Momentum.controller<ImplementsABCTypesController>(
              context,
            ).multiplyBy(2);
          },
          child: Text('Multiply by 2'),
        ),
        FlatButton(
          key: keyTypeTestDivideButton,
          onPressed: () {
            Momentum.controller<ImplementsABCTypesController>(
              context,
            ).divideBy(2);
          },
          child: Text('Divide by 2'),
        ),
        FlatButton(
          key: keyTypeTestToSquareButton,
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
