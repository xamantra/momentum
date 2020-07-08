import 'package:flutter/material.dart';
import 'package:momentum/momentum.dart';

import '../components/router-param/index.dart';

const routerParamsBTestButtonKey = Key('routerParamsBTestButtonKey');
const routerParamsCTestButtonKey = Key('routerParamsCTestButtonKey');
const routerParamsDTestButtonKey = Key('routerParamsDTestButtonKey');

Momentum routerParamsTest() {
  return Momentum(
    child: BasePage(),
    controllers: [
      RouterParamController(),
    ],
    services: [
      Router([
        RouterParamsTestA(),
        RouterParamsTestB(),
        RouterParamsTestC(),
        RouterParamsTestD(),
      ]),
    ],
  );
}

class TestRouterParamsB {
  final String value;

  TestRouterParamsB(this.value);
}

class TestRouterParamsC {
  final String value;

  TestRouterParamsC(this.value);
}

class BasePage extends StatelessWidget {
  const BasePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BasePage',
      home: Router.getActivePage(context),
    );
  }
}

class RouterParamsTestA extends StatelessWidget {
  const RouterParamsTestA({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Text('RouterParamsTestA'),
          FlatButton(
            key: routerParamsBTestButtonKey,
            onPressed: () {
              Router.goto(
                context,
                RouterParamsTestB,
                params: TestRouterParamsB('Hello World'),
              );
            },
            child: Text('Goto B'),
          ),
          FlatButton(
            key: routerParamsCTestButtonKey,
            onPressed: () {
              Router.goto(
                context,
                RouterParamsTestC,
                params: TestRouterParamsB('Hello World'),
              );
            },
            child: Text('Goto C'),
          ),
          FlatButton(
            key: routerParamsDTestButtonKey,
            onPressed: () {
              Router.goto(
                context,
                RouterParamsTestD,
                params: TestRouterParamsC('Flutter is awesome!'),
              );
            },
            child: Text('Goto D'),
          ),
        ],
      ),
    );
  }
}

class RouterParamsTestB extends StatelessWidget {
  const RouterParamsTestB({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Text(Router.getParams<TestRouterParamsB>(context).value),
    );
  }
}

class RouterParamsTestC extends StatelessWidget {
  const RouterParamsTestC({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Text(Router.getParams<TestRouterParamsC>(context).value),
        ],
      ),
    );
  }
}

class RouterParamsTestD extends StatelessWidget {
  const RouterParamsTestD({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var controller = Momentum.controller<RouterParamController>(context);
    return Scaffold(
      body: Column(
        children: <Widget>[
          Text(controller.getParamValue()),
        ],
      ),
    );
  }
}
