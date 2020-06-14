import 'package:flutter/material.dart';
import 'package:momentum/momentum.dart';

import '../components/types-test/index.dart';

const keyTypeTestIncrementButton = Key('keyTypeTestIncrementButton');
const keyTypeTestDecrementButton = Key('keyTypeTestDecrementButton');
const keyTypeTestMultiplyButton = Key('keyTypeTestMultiplyButton');
const keyTypeTestDivideButton = Key('keyTypeTestDivideButton');
const keyTypeTestToSquareButton = Key('keyTypeTestToSquareButton');

Momentum typesTestWidget() {
  return Momentum(
    child: _TypesTestApp(),
    controllers: [
      ATypesTestController()..config(maxTimeTravelSteps: 10),
      BTypesTestController(),
      CTypesTestController(),
      ImplementsABCTypesController(),
    ],
  );
}

class _TypesTestApp extends StatelessWidget {
  const _TypesTestApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Counter App',
      home: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: _TypesTestWidgets(),
          ),
        ),
      ),
    );
  }
}

class _TypesTestWidgets extends StatelessWidget {
  const _TypesTestWidgets({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        MomentumBuilder(
          controllers: [ATypesTestController],
          builder: (context, snapshot) {
            var typeTest = snapshot<TypesTestModel>();
            return Text('$ATypesTestController: ${typeTest.value}');
          },
        ),
        MomentumBuilder(
          controllers: [BTypesTestController],
          builder: (context, snapshot) {
            var typeTest = snapshot<TypesTestModel>();
            return Text('$BTypesTestController: ${typeTest.value}');
          },
        ),
        MomentumBuilder(
          controllers: [CTypesTestController],
          builder: (context, snapshot) {
            var typeTest = snapshot<TypesTestModel>();
            return Column(
              children: <Widget>[
                Text('$CTypesTestController.value: ${typeTest.value}'),
                Text(
                  '$CTypesTestController.square: ${typeTest.squareRoot}',
                ),
              ],
            );
          },
        ),
        MomentumBuilder(
          controllers: [ImplementsABCTypesController],
          builder: (context, snapshot) {
            var typeTest = snapshot<TypesTestModel>();
            return Column(
              children: <Widget>[
                Text(
                  '$ImplementsABCTypesController.value: ${typeTest.value}',
                ),
                Text(
                  '$ImplementsABCTypesController.square: ${typeTest.squareRoot}',
                ),
              ],
            );
          },
        ),
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
