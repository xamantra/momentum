import 'package:flutter/material.dart';
import 'package:momentum/momentum.dart';
import '../../../src/momentum/counter/counter.model.dart';
import '../../../src/momentum/counter/counter.controller.dart';

class CounterPage extends StatefulWidget {
  @override
  _CounterPageState createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  CounterController counterController; // you can't make this final because context variables requires BuildContext. So it can only be set on build method. It means you can't also do this in StatelessWidget.

  @override
  Widget build(BuildContext context) {
    counterController = Momentum.of<CounterController>(context); // simply grab a controller using generic. You can't do this in StatelessWidget because stateless widgets must be immutable. But, if your widget doesn't need to call a function from any controller, you can just use StatelessWidget.
    return Scaffold(
      appBar: AppBar(
        title: Text("Counter"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            MomentumBuilder(
              controllers: [CounterController], // super cool dependency injection, injected a type instead of an instance. the library will look up the type for you and actually inject it behind the scenes.
              builder: (context, snapshot) {
                var counter = snapshot<CounterModel>(); // simply grab a model using generic.
                return Text(
                  '${counter.value}',
                  style: Theme.of(context).textTheme.headline4,
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: counterController.increment, // calls a function in the controller
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}
