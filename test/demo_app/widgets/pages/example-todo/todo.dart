import 'package:flutter/material.dart';
import 'package:momentum/momentum.dart';
import 'package:relative_scale/relative_scale.dart';

import '../../../components/todo-example/index.dart';
import '../../index.dart';
import 'index.dart';

const backButtonKey = Key('TodoExamplePage#BackButton');

class TodoExamplePage extends StatefulWidget {
  const TodoExamplePage({Key? key}) : super(key: key);

  @override
  _TodoExamplePageState createState() => _TodoExamplePageState();
}

class _TodoExamplePageState extends MomentumState<TodoExamplePage> {
  late TodoExampleController todoController;
  @override
  void initMomentumState() {
    super.initMomentumState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    todoController = Momentum.controller<TodoExampleController>(context);
    var initial = todoController.model.todoMap!.keys;
    if (initial.isNotEmpty) {
      todoController.eventTodoName = initial.last;
    }
    todoController.addListener(
      state: this,
      invoke: (state, _) {
        todoController.eventTodoName = state.todoMap!.keys.last;
      },
    );
  }

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
                'TODO List Example',
                style: TextStyle(
                  fontSize: sy(11.5),
                ),
              ),
              leading: BackButton(key: backButtonKey),
            ),
            body: Center(
              child: MomentumBuilder(
                controllers: [TodoExampleController],
                builder: (context, snapshot) {
                  var todoModel = snapshot<TodoExampleModel>();

                  var map = todoModel.todoMap!;
                  var titles = map.keys.toList();

                  return Column(
                    children: [
                      Note(note: 'NOTE: Add some TODOs and try to close then open the app again. Everything will be saved. Including check states. This is one of Momentum\'s capability.'),
                      Expanded(
                        child: ListView.builder(
                          physics: BouncingScrollPhysics(),
                          itemCount: titles.length,
                          itemBuilder: (context, index) {
                            var title = titles[index];
                            var checked = map[title]!;
                            return InkWell(
                              onTap: () {
                                todoModel.controller.toggleTodo(title, !checked);
                              },
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ListTile(
                                          title: Text(
                                            title,
                                            style: TextStyle(
                                              color: Colors.white.withOpacity(checked ? 0.3 : 1),
                                              decoration: checked ? TextDecoration.lineThrough : TextDecoration.none,
                                            ),
                                          ),
                                          dense: true,
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.close,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          todoController.removeTodo(title);
                                        },
                                      ),
                                      Checkbox(
                                        value: checked,
                                        activeColor: Theme.of(context).accentColor,
                                        onChanged: (value) {
                                          todoModel.controller.toggleTodo(title, value ?? false);
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
                    ],
                  );
                },
              ),
            ),
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add),
              onPressed: () async {
                var title = await showTodoPrompt(context);
                if (title != null) {
                  todoController.addTodo(title);
                }
              },
            ),
          );
        },
      ),
    );
  }
}
