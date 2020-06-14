import 'package:flutter/material.dart';
import 'package:momentum/momentum.dart';

import '../components/type-test/index.dart';

const keyTypeTestIncrementButton = Key('keyTypeTestIncrementButton');
const keyTypeTestDecrementButton = Key('keyTypeTestDecrementButton');
const keyTypeTestMultiplyButton = Key('keyTypeTestMultiplyButton');
const keyTypeTestDivideButton = Key('keyTypeTestDivideButton');
const keyTypeTestToSquareButton = Key('keyTypeTestToSquareButton');

Momentum typeTestWidget() {
  return Momentum(
    child: _TypeTestApp(),
    controllers: [
      ATypeTestController()..config(maxTimeTravelSteps: 10),
      BTypeTestController(),
      CTypeTestController(),
      ImplementsABCTypeController(),
    ],
  );
}

class _TypeTestApp extends StatelessWidget {
  const _TypeTestApp({Key key}) : super(key: key);

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
          controllers: [ATypeTestController],
          builder: (context, snapshot) {
            var typeTest = snapshot<TypeTestModel>();
            return Text('$ATypeTestController: ${typeTest.value}');
          },
        ),
        MomentumBuilder(
          controllers: [BTypeTestController],
          builder: (context, snapshot) {
            var typeTest = snapshot<TypeTestModel>();
            return Text('$BTypeTestController: ${typeTest.value}');
          },
        ),
        MomentumBuilder(
          controllers: [CTypeTestController],
          builder: (context, snapshot) {
            var typeTest = snapshot<TypeTestModel>();
            return Column(
              children: <Widget>[
                Text('$CTypeTestController.value: ${typeTest.value}'),
                Text(
                  '$CTypeTestController.square: ${typeTest.squareRoot}',
                ),
              ],
            );
          },
        ),
        MomentumBuilder(
          controllers: [ImplementsABCTypeController],
          builder: (context, snapshot) {
            var typeTest = snapshot<TypeTestModel>();
            return Column(
              children: <Widget>[
                Text(
                  '$ImplementsABCTypeController.value: ${typeTest.value}',
                ),
                Text(
                  '$ImplementsABCTypeController.square: ${typeTest.squareRoot}',
                ),
              ],
            );
          },
        ),
        FlatButton(
          key: keyTypeTestIncrementButton,
          onPressed: () {
            Momentum.controller<ImplementsABCTypeController>(
              context,
            ).increment();
          },
          child: Text('Increment'),
        ),
        FlatButton(
          key: keyTypeTestDecrementButton,
          onPressed: () {
            Momentum.controller<ImplementsABCTypeController>(
              context,
            ).decrement();
          },
          child: Text('Decrement'),
        ),
        FlatButton(
          key: keyTypeTestMultiplyButton,
          onPressed: () {
            Momentum.controller<ImplementsABCTypeController>(
              context,
            ).multiplyBy(2);
          },
          child: Text('Multiply by 2'),
        ),
        FlatButton(
          key: keyTypeTestDivideButton,
          onPressed: () {
            Momentum.controller<ImplementsABCTypeController>(
              context,
            ).divideBy(2);
          },
          child: Text('Divide by 2'),
        ),
        FlatButton(
          key: keyTypeTestToSquareButton,
          onPressed: () {
            Momentum.controller<ImplementsABCTypeController>(
              context,
            ).square();
          },
          child: Text('To Square'),
        ),
      ],
    );
  }
}
