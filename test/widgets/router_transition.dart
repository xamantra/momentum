import 'package:flutter/material.dart';
import 'package:momentum/momentum.dart';
import 'package:momentum/momentum.dart' as momentum;
import 'package:momentum/src/in_memory_storage.dart';

import '../components/counter/index.dart';

const transitionToBKey = Key('transitionToBKey');
const transitionToCKey = Key('transitionToCKey');
const transitionCPop = Key('transitionCPop');

Momentum routerTransitionTest() {
  return Momentum(
    child: MyApp(),
    controllers: [CounterController()],
    services: [
      momentum.MomentumRouter([
        TransitionPageA(),
        TransitionPageB(),
        TransitionPageC(),
      ]),
      InMemoryStorage(),
    ],
    persistSave: (context, key, value) async {
      var storage = InMemoryStorage.of('routerTransitionTest', context);
      var result = await storage.setString(key, value);
      return result;
    },
    persistGet: (context, key) async {
      var storage = InMemoryStorage.of('routerTransitionTest', context);
      var result = storage.getString(key);
      return result;
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Counter App',
      home: momentum.MomentumRouter.getActivePage(context),
    );
  }
}

class TransitionPageA extends StatelessWidget {
  const TransitionPageA({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FlatButton(
          key: transitionToBKey,
          onPressed: () {
            momentum.MomentumRouter.goto(
              context,
              TransitionPageB,
              transition: (context, page) {
                return MaterialPageRoute(builder: (context) => page);
              },
            );
          },
          child: Text('Goto PageB'),
        ),
      ),
    );
  }
}

class TransitionPageB extends StatelessWidget {
  const TransitionPageB({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FlatButton(
          key: transitionToCKey,
          onPressed: () {
            momentum.MomentumRouter.goto(
              context,
              TransitionPageC,
              transition: (context, page) {
                return MaterialPageRoute(builder: (context) => page);
              },
            );
          },
          child: Text('Goto PageC'),
        ),
      ),
    );
  }
}

class TransitionPageC extends StatelessWidget {
  const TransitionPageC({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FlatButton(
          key: transitionCPop,
          onPressed: () {
            momentum.MomentumRouter.pop(context, transition: (context, page) {
              return MaterialPageRoute(builder: (context) => page);
            });
          },
          child: Text('Goto PageC'),
        ),
      ),
    );
  }
}
