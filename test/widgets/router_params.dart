import 'package:flutter/material.dart';
import 'package:momentum/momentum.dart';
import 'package:momentum/src/in_memory_storage.dart';

import '../components/router-param-mixin/index.dart';
import '../components/router-param/index.dart';

const routerParamsBTestButtonKey = Key('routerParamsBTestButtonKey');
const routerParamsCTestButtonKey = Key('routerParamsCTestButtonKey');
const routerParamsDTestButtonKey = Key('routerParamsDTestButtonKey');
const routerParamsDErrorButtonKey = Key('routerParamsDErrorButtonKey');
const routerParamsPopButtonKey = Key('routerParamsPopButtonKey');

Momentum routerParamsTest([String sessionKey]) {
  return Momentum(
    child: BasePage(),
    controllers: [
      RouterParamController(),
      RouterParamMixinController(),
    ],
    services: [
      Router([
        RouterParamsTestA(),
        RouterParamsTestB(),
        RouterParamsTestC(),
        RouterParamsTestD(),
        RouterParamsTestE(),
      ]),
      InMemoryStorage(),
    ],
    persistSave: (context, key, value) async {
      var storage = InMemoryStorage.of(
        sessionKey ?? 'routerParamsTest',
        context,
      );
      var result = storage.setString(key, value);
      return result;
    },
    persistGet: (context, key) async {
      var storage = InMemoryStorage.of(
        sessionKey ?? 'routerParamsTest',
        context,
      );
      var result = storage.getString(key);
      return result;
    },
  );
}

class TestRouterParamsB extends RouterParam {
  final String value;

  TestRouterParamsB(this.value);

  static TestRouterParamsB fromJson(Map<String, dynamic> json) {
    return TestRouterParamsB(json['value']);
  }

  Map<String, dynamic> toJson() {
    return {'value': value};
  }
}

class TestRouterParamsC extends RouterParam {
  final String value;

  TestRouterParamsC(this.value);

  static TestRouterParamsC fromJson(Map<String, dynamic> json) {
    return TestRouterParamsC(json['value']);
  }

  Map<String, dynamic> toJson() {
    return {'value': value};
  }
}

class TestRouterParamsD extends RouterParam {
  final String value;

  TestRouterParamsD(this.value);

  static TestRouterParamsD fromJson(Map<String, dynamic> json) {
    return TestRouterParamsD(json['value']);
  }

  Map<String, dynamic> toJson() => throw UnimplementedError();
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
    var params = Router.getParam<TestRouterParamsB>(context);
    return Scaffold(
      body: Text(params.value),
    );
  }
}

class RouterParamsTestC extends StatelessWidget {
  const RouterParamsTestC({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var params = Router.getParam<TestRouterParamsC>(context);
    return Scaffold(
      body: Column(
        children: <Widget>[
          Text(params.value),
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
          FlatButton(
            key: routerParamsDErrorButtonKey,
            onPressed: () {
              Router.goto(
                context,
                RouterParamsTestE,
                params: TestRouterParamsD('12345'),
              );
            },
            child: Text(''),
          ),
        ],
      ),
    );
  }
}

class RouterParamsTestE extends StatelessWidget {
  const RouterParamsTestE({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var params = Router.getParam<TestRouterParamsD>(context);
    return Scaffold(
      body: Column(
        children: <Widget>[
          Text(params.value),
          FlatButton(
            key: routerParamsPopButtonKey,
            onPressed: () {
              Router.pop(
                context,
                result: TestRouterParamsC('789'),
              );
            },
            child: Text(''),
          ),
        ],
      ),
    );
  }
}
