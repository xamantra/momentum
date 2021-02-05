import 'package:flutter/material.dart';
import 'package:momentum/momentum.dart';
import 'package:relative_scale/relative_scale.dart';

import '../../../components/basic-list/index.dart';

class BasicListExamplePage extends StatelessWidget {
  const BasicListExamplePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var controller = Momentum.controller<BasicListExampleController>(context);
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
