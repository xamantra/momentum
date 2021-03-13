import 'package:flutter/material.dart';
import 'package:momentum/momentum.dart';
import 'package:relative_scale/relative_scale.dart';

import '../../../components/basic-list-example/index.dart';

class BasicListExamplePage extends StatefulWidget {
  const BasicListExamplePage({Key key}) : super(key: key);

  @override
  _BasicListExamplePageState createState() => _BasicListExamplePageState();
}

class _BasicListExamplePageState extends MomentumState<BasicListExamplePage> {
  BasicListExampleController controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    controller = Momentum.controller<BasicListExampleController>(context);
    controller.listen<BasicListEvent>(
      state: this,
      invoke: (event) {
        switch (event) {
          case BasicListEvent.reverseList:
            controller.reverseListUpdate();
            break;
          case BasicListEvent.clearList:
            controller.clearListUpdate();
            break;
          case BasicListEvent.resetAll:
            Momentum.resetAll(context);
            break;
          case BasicListEvent.resetAllClearHistory:
            Momentum.resetAll(context, clearHistory: true);
            break;
          case BasicListEvent.restart:
            Momentum.restart(context, null);
            break;
        }
      },
    );
    controller.listen<RestartEvent>(
      state: this,
      invoke: (event) {
        Momentum.restart(context, event.instance);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return RelativeBuilder(
      builder: (context, height, width, sy, sx) {
        return Scaffold(
          backgroundColor: Theme.of(context).backgroundColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).backgroundColor,
            title: Text(
              'Basic List (Undo/Redo)',
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

                return ListView.builder(
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
    );
  }
}
