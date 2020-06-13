import 'package:flutter/material.dart';
import 'package:momentum/momentum.dart';

import '../components/counter/index.dart';
import '../utility.dart';

const transitionToBKey = Key('transitionToBKey');
const transitionToCKey = Key('transitionToCKey');
const transitionCPop = Key('transitionCPop');

Momentum routerTransitionTest() {
  return Momentum(
    child: MyApp(),
    controllers: [CounterController()],
    services: [
      Router([
        TransitionPageA(),
        TransitionPageB(),
        TransitionPageC(),
      ]),
      InMemoryStorage<String>(),
    ],
    persistSave: (context, key, value) async {
      var storage = InMemoryStorage.of<String>('routerTransitionTest', context);
      var result = await storage.save(key, value);
      return result;
    },
    persistGet: (context, key) async {
      var storage = InMemoryStorage.of<String>('routerTransitionTest', context);
      var result = storage.getValue(key);
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
      home: Router.getActivePage(context),
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
            Router.goto(context, TransitionPageB, transition: (context, page) {
              return MaterialPageRoute(builder: (context) => page);
            });
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
            Router.goto(context, TransitionPageC, transition: (context, page) {
              return MaterialPageRoute(builder: (context) => page);
            });
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
            Router.pop(context, transition: (context, page) {
              return MaterialPageRoute(builder: (context) => page);
            });
          },
          child: Text('Goto PageC'),
        ),
      ),
    );
  }
}
