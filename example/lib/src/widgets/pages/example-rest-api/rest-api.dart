import 'package:flutter/material.dart';
import 'package:momentum/momentum.dart';
import 'package:relative_scale/relative_scale.dart';

import '../../../components/rest-api-example/index.dart';

class RestApiExamplePage extends StatefulWidget {
  const RestApiExamplePage({Key key}) : super(key: key);

  @override
  _RestApiExamplePageState createState() => _RestApiExamplePageState();
}

class _RestApiExamplePageState extends State<RestApiExamplePage> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Primary way to access a specific controller in a widget using context.
    // You can also set this as class wide property.
    var controller = Momentum.controller<RestApiExampleController>(context);

    // controller.loadTodoList();
    controller.loadTodoList_V2();
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
              'Momentum - REST API Example',
              style: TextStyle(
                fontSize: sy(11.5),
              ),
            ),
          ),
          body: Center(
            child: MomentumBuilder(
              controllers: [RestApiExampleController],
              builder: (context, snapshot) {
                var timerModel = snapshot<RestApiExampleModel>();

                var list = timerModel.todoList?.list ?? [];

                if (timerModel.isLoading) {
                  return CircularProgressIndicator();
                } else {
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
                                    title: Text(item.title),
                                    dense: true,
                                  ),
                                ),
                                Checkbox(
                                  value: item.completed, // take note this is only a readonly example. the check states boolean are from jsonplaceholder website.
                                  onChanged: (_) {},
                                ),
                              ],
                            ),
                            Divider(height: 1),
                          ],
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        );
      },
    );
  }
}