import 'package:flutter/material.dart';
import 'package:momentum/momentum.dart';
import 'package:relative_scale/relative_scale.dart';

import '../../../components/basic-list-example/index.dart';
import '../home/index.dart';

const basicListBackButton = Key('basicListBackButton');
const clearRouterButton = Key('clearRouterButton');
const resetRouterButton = Key('resetRouterButton');

class BasicListRoutedPage extends StatelessWidget {
  const BasicListRoutedPage({
    Key key,
    this.withTransition = false,
  }) : super(key: key);

  final bool withTransition;

  @override
  Widget build(BuildContext context) {
    var controller = Momentum.controller<BasicListExampleController>(context);
    return RouterPage(
      onWillPop: () async {
        controller.clearListUpdate();
        controller.add('Orange');
        MomentumRouter.pop(
          context,
          transition: !withTransition
              ? null
              : (_, page) => MaterialPageRoute(
                    builder: (_) => page,
                  ),
        );
        return true;
      },
      child: RelativeBuilder(
        builder: (context, height, width, sy, sx) {
          return Scaffold(
            backgroundColor: Theme.of(context).backgroundColor,
            appBar: AppBar(
              backgroundColor: Theme.of(context).backgroundColor,
              leading: BackButton(key: basicListBackButton),
              title: Text(
                'Basic List (routed)',
                style: TextStyle(
                  fontSize: sy(11.5),
                ),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.undo),
                  onPressed: controller.undo,
                ),
                IconButton(
                  icon: Icon(Icons.redo),
                  onPressed: controller.redo,
                ),
              ],
            ),
            body: Center(
              child: MomentumBuilder(
                controllers: [BasicListExampleController],
                builder: (context, snapshot) {
                  var listModel = snapshot<BasicListExampleModel>();

                  var list = listModel.list;

                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          physics: BouncingScrollPhysics(),
                          itemCount: list.length,
                          itemBuilder: (context, index) {
                            var item = list[index];
                            return InkWell(
                              key: Key('BasicItem-#$index'),
                              onTap: () {},
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ListTile(
                                          title: Text(item),
                                          dense: true,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.close),
                                        onPressed: () {
                                          listModel.controller.remove(index);
                                        },
                                      ),
                                    ],
                                  ),
                                  Divider(height: 1),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            key: clearRouterButton,
                            icon: Icon(Icons.clear),
                            onPressed: () async {
                              await MomentumRouter.clearHistoryWithContext(context);
                            },
                          ),
                          IconButton(
                            key: resetRouterButton,
                            icon: Icon(Icons.clear),
                            onPressed: () async {
                              await MomentumRouter.resetWithContext<HomePage>(context);
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MomentumRouter.getActivePage(context),
                                ),
                                (r) => false,
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: controller.addNewRandom,
            ),
          );
        },
      ),
    );
  }
}
