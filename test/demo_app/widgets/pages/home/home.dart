import 'package:flutter/material.dart';
import 'package:momentum/momentum.dart';
import 'package:relative_scale/relative_scale.dart';

import '../example-basic-list-routed/index.dart';
import '../example-basic-list/index.dart';
import '../example-calculator/index.dart';
import '../example-rest-api/index.dart';
import '../example-timer/index.dart';
import '../example-todo/index.dart';
import 'index.dart';

const homeBackButton = Key('homeBackButton');
const basicListMenuKey = Key('basicListMenuKey');
const todoListMenuKey = Key('todoListMenuKey');

class HomePage extends StatelessWidget {
  const HomePage({
    Key? key,
    this.withTransition = false,
  }) : super(key: key);

  final bool withTransition;

  @override
  Widget build(BuildContext context) {
    return RouterPage(
      child: RelativeBuilder(
        builder: (context, height, width, sy, sx) {
          return Scaffold(
            backgroundColor: Theme.of(context).backgroundColor,
            appBar: AppBar(
              backgroundColor: Theme.of(context).backgroundColor,
              title: Text(
                'Momentum Flutter Demo',
              ),
              leading: BackButton(key: homeBackButton),
            ),
            body: Container(
              height: height,
              width: width,
              padding: EdgeInsets.all(sy(8)),
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  children: [
                    ExampleItem(name: 'Simple Timer Example', page: TimerExamplePage()),
                    ExampleItem(name: 'REST API Example', page: RestApiExamplePage()),
                    ExampleItem(name: 'Basic List (Undo/Redo) Example', page: BasicListExamplePage()),
                    ExampleItem(
                      key: basicListMenuKey,
                      name: 'Basic List (routed) Example',
                      route: BasicListRoutedPage,
                      withTransition: withTransition,
                      parameter: BasicListRouteParam(
                        ['Flutter', 'Dart', 'Google'],
                      ),
                    ),
                    ExampleItem(
                      name: 'TODO List Example',
                      page: TodoExamplePage(),
                    ),
                    ExampleItem(
                      key: todoListMenuKey,
                      name: 'TODO List Example (routed)',
                      route: TodoExamplePage,
                      withTransition: withTransition,
                      page: TodoExamplePage(),
                    ),
                    ExampleItem(name: 'Basic Calculator Example', page: CalculatorExamplePage()),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
