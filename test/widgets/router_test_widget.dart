import 'package:flutter/material.dart';
import 'package:momentum/momentum.dart';
import 'package:momentum/momentum.dart' as momentum;
import 'package:momentum/src/in_memory_storage.dart';

import '../components/counter/index.dart';

const gotoPageBKey = Key('Goto PageB');
const gotoPageCKey = Key('Goto PageC');
const fromPageCPop = Key('From PageC Pop');
const clearHistoryButton = Key('clearHistoryButton');
const resetHistoryButton = Key('resetHistoryButton');

Momentum routerTestWidget({
  bool testMode,
  String sessionName,
}) {
  return Momentum(
    testMode: testMode,
    testSessionName: sessionName,
    child: MyApp(),
    controllers: [CounterController()],
    services: [
      momentum.MomentumRouter([
        PageA(),
        PageB(),
        PageC(),
      ]),
      InMemoryStorage(),
    ],
    persistSave: (context, key, value) async {
      var storage = InMemoryStorage.of('routerTestWidget', context);
      var result = await storage.setString(key, value);
      return result;
    },
    persistGet: (context, key) async {
      var storage = InMemoryStorage.of('routerTestWidget', context);
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

class PageA extends StatelessWidget {
  const PageA({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            FlatButton(
              key: gotoPageBKey,
              onPressed: () {
                momentum.MomentumRouter.goto(context, PageB);
              },
              child: Text('Goto PageB'),
            ),
            FlatButton(
              key: resetHistoryButton,
              onPressed: () {
                momentum.MomentumRouter.resetWithContext<PageB>(context);
              },
              child: Text('Reset Router'),
            ),
          ],
        ),
      ),
    );
  }
}

class PageB extends StatelessWidget {
  const PageB({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FlatButton(
          key: gotoPageCKey,
          onPressed: () {
            momentum.MomentumRouter.goto(context, PageC);
          },
          child: Text('Goto PageC'),
        ),
      ),
    );
  }
}

class PageC extends StatelessWidget {
  const PageC({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: <Widget>[
            FlatButton(
              key: fromPageCPop,
              onPressed: () {
                momentum.MomentumRouter.pop(context);
              },
              child: Text('Pop From PageC'),
            ),
            FlatButton(
              key: clearHistoryButton,
              onPressed: () {
                momentum.MomentumRouter.clearHistoryWithContext(context);
              },
              child: Text('Clear History'),
            ),
          ],
        ),
      ),
    );
  }
}
