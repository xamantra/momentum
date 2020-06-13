import 'package:flutter/material.dart';
import 'package:momentum/momentum.dart';

import '../components/counter/index.dart';
import '../utility.dart';

const gotoPageBKey = Key('Goto PageB');
const gotoPageCKey = Key('Goto PageC');
const fromPageCPop = Key('From PageC Pop');

Momentum routerTestWidget() {
  return Momentum(
    child: MyApp(),
    controllers: [CounterController()],
    services: [
      Router([
        PageA(),
        PageB(),
        PageC(),
      ]),
      InMemoryStorage<String>(),
    ],
    persistSave: (context, key, value) async {
      var storage = InMemoryStorage.of<String>(context);
      var result = await storage.save(key, value);
      return result;
    },
    persistGet: (context, key) async {
      var storage = InMemoryStorage.of<String>(context);
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

class PageA extends StatelessWidget {
  const PageA({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FlatButton(
          key: gotoPageBKey,
          onPressed: () {
            Router.goto(context, PageB);
          },
          child: Text('Goto PageB'),
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
            Router.goto(context, PageC);
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
        child: FlatButton(
          key: fromPageCPop,
          onPressed: () {
            Router.pop(context);
          },
          child: Text('Goto PageC'),
        ),
      ),
    );
  }
}
