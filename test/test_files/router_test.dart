import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/momentum.dart';

import '../demo_app/components/basic-list-example/index.dart';
import '../demo_app/components/todo-example/index.dart';
import '../demo_app/widgets/pages/example-basic-list-routed/index.dart';
import '../demo_app/widgets/pages/example-todo/index.dart';
import '../demo_app/widgets/pages/home/index.dart';

void main() {
  group('Test basic routing', () {
    var momentumRouter = MomentumRouter([
      HomePage(),
      BasicListRoutedPage(),
      TodoExamplePage(),
    ]);
    Momentum root() {
      return Momentum(
        key: UniqueKey(),
        controllers: [BasicListExampleController(), TodoExampleController()],
        services: [momentumRouter],
        child: MaterialApp(
          home: Builder(
            builder: (context) => MomentumRouter.getActivePage(context),
          ),
        ),
      );
    }

    testWidgets('Test goto and pop', (tester) async {
      await tester.pumpWidget(root());
      await tester.pumpAndSettle();

      var homeAppbarTitle = find.text('Momentum Flutter Demo');
      expect(homeAppbarTitle, findsOneWidget);
      var basicListMenu = find.byKey(basicListMenuKey);
      expect(basicListMenu, findsOneWidget);

      await tester.tap(basicListMenu);
      await tester.pumpAndSettle();

      var basicListAppbarTitle = find.text('Basic List (routed)');
      expect(basicListAppbarTitle, findsOneWidget);

      await tester.tap(find.byKey(basicListBackButton));
      await tester.pumpAndSettle();
      homeAppbarTitle = find.text('Momentum Flutter Demo');
      expect(homeAppbarTitle, findsOneWidget);
      basicListMenu = find.byKey(basicListMenuKey);
      expect(basicListMenu, findsOneWidget);

      await tester.tap(find.byKey(homeBackButton));
      await tester.pumpAndSettle();
      expect(momentumRouter.exited, true);
    });
  });

  group('Test persisted routing', () {
    var inMemoryStorage = <String?, String?>{};
    Momentum root() {
      return Momentum(
        key: UniqueKey(),
        controllers: [BasicListExampleController(), TodoExampleController()],
        services: [
          MomentumRouter([
            HomePage(withTransition: true),
            BasicListRoutedPage(withTransition: true),
            TodoExamplePage(),
          ]),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) => MomentumRouter.getActivePage(context),
          ),
        ),
        persistSave: (context, key, value) async {
          inMemoryStorage.putIfAbsent(key, () => value);
          inMemoryStorage[key] = value;
          return true;
        },
        persistGet: (context, key) async {
          try {
            return inMemoryStorage[key];
          } catch (e) {
            return null;
          }
        },
      );
    }

    testWidgets('Test goto and pop (1st run)', (tester) async {
      await tester.pumpWidget(root());
      await tester.pumpAndSettle();

      var homeAppbarTitle = find.text('Momentum Flutter Demo');
      expect(homeAppbarTitle, findsOneWidget);
      var basicListMenu = find.byKey(basicListMenuKey);
      expect(basicListMenu, findsOneWidget);

      await tester.tap(basicListMenu);
      await tester.pumpAndSettle();

      var basicListAppbarTitle = find.text('Basic List (routed)');
      expect(basicListAppbarTitle, findsOneWidget);

      await tester.tap(find.byKey(basicListBackButton));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(todoListMenuKey));
      await tester.pumpAndSettle();
      expect(find.text('TODO List Example'), findsOneWidget);
    });

    testWidgets('Test goto and pop (2nd run)', (tester) async {
      await tester.pumpWidget(root());
      await tester.pumpAndSettle();

      expect(find.text('TODO List Example'), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(find.text('Momentum Flutter Demo'), findsOneWidget);
    });
  });

  group('Test routing management (clear and reset)', () {
    var inMemoryStorage = <String, String?>{};
    var momentumRouter = MomentumRouter([
      HomePage(),
      BasicListRoutedPage(),
      TodoExamplePage(),
    ]);
    Momentum root() {
      return Momentum(
        key: UniqueKey(),
        controllers: [BasicListExampleController(), TodoExampleController()],
        services: [momentumRouter],
        child: MaterialApp(
          home: Builder(
            builder: (context) => MomentumRouter.getActivePage(context),
          ),
        ),
        persistSave: (context, key, value) async {
          inMemoryStorage.putIfAbsent(key, () => value);
          inMemoryStorage[key] = value;
          return true;
        },
        persistGet: (context, key) async {
          try {
            return inMemoryStorage[key];
          } catch (e) {
            return null;
          }
        },
      );
    }

    testWidgets('Test goto -> pop -> clear and reset', (tester) async {
      await tester.pumpWidget(root());
      await tester.pumpAndSettle();

      var homeAppbarTitle = find.text('Momentum Flutter Demo');
      expect(homeAppbarTitle, findsOneWidget);
      var basicListMenu = find.byKey(basicListMenuKey);
      expect(basicListMenu, findsOneWidget);

      await tester.tap(basicListMenu);
      await tester.pumpAndSettle();

      var basicListAppbarTitle = find.text('Basic List (routed)');
      expect(basicListAppbarTitle, findsOneWidget);

      await tester.tap(find.byKey(clearRouterButton));
      await tester.pumpAndSettle();
      expect(momentumRouter.isRoutesEmpty, true);

      await tester.tap(find.byKey(resetRouterButton));
      await tester.pumpAndSettle();
      homeAppbarTitle = find.text('Momentum Flutter Demo');
      expect(homeAppbarTitle, findsOneWidget);
      basicListMenu = find.byKey(basicListMenuKey);
      expect(basicListMenu, findsOneWidget);
      expect(momentumRouter.isRoutesEmpty, false);
    });
  });

  group('Test misconfigured routing', () {
    Momentum root() {
      return Momentum(
        key: UniqueKey(),
        controllers: [BasicListExampleController(), TodoExampleController()],
        services: [
          MomentumRouter([
            HomePage(),
          ]),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) => MomentumRouter.getActivePage(context),
          ),
        ),
      );
    }

    testWidgets('Test goto and pop', (tester) async {
      await tester.pumpWidget(root());
      await tester.pumpAndSettle();

      var homeAppbarTitle = find.text('Momentum Flutter Demo');
      expect(homeAppbarTitle, findsOneWidget);
      var basicListMenu = find.byKey(basicListMenuKey);
      expect(basicListMenu, findsOneWidget);

      await tester.tap(basicListMenu);
      await tester.pumpAndSettle();

      expect(find.text('Momentum Flutter Demo'), findsOneWidget);
      expect(find.byKey(basicListMenuKey), findsOneWidget);
    });
  });
}
