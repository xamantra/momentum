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
      ATypesTestCtrl()..config(maxTimeTravelSteps: 10),
      BTypesTestCtrl(),
      CTypesTestCtrl(),
      ImplementsABCTypesCtrl(),
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
          controllers: [ATypesTestCtrl],
          builder: (context, snapshot) {
            var typeTest = snapshot<ATypesTestModel>();
            return Text('$ATypesTestCtrl: ${typeTest.value}');
          },
        ),
        MomentumBuilder(
          controllers: [BTypesTestCtrl],
          builder: (context, snapshot) {
            var typeTest = snapshot<ATypesTestModel>();
            return Text('$BTypesTestCtrl: ${typeTest.value}');
          },
        ),
        MomentumBuilder(
          controllers: [CTypesTestCtrl],
          builder: (context, snapshot) {
            var typeTest = snapshot<ATypesTestModel>();
            return Column(
              children: <Widget>[
                Text('$CTypesTestCtrl.value: ${typeTest.value}'),
                Text(
                  '$CTypesTestCtrl.square: ${typeTest.square}',
                ),
              ],
            );
          },
        ),
        MomentumBuilder(
          controllers: [ImplementsABCTypesCtrl],
          builder: (context, snapshot) {
            var typeTest = snapshot<ATypesTestModel>();
            return Column(
              children: <Widget>[
                Text(
                  '$ImplementsABCTypesCtrl.value: ${typeTest.value}',
                ),
                Text(
                  '$ImplementsABCTypesCtrl.square: ${typeTest.square}',
                ),
              ],
            );
          },
        ),
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
