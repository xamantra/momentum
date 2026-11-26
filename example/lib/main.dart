import 'package:material_ui/material_ui.dart';
import 'package:momentum/momentum.dart';

void main() {
  runApp(momentum());
}

Momentum momentum() {
  return Momentum(
    controllers: [CounterController()],
    child: const MyApp(),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Momentum State Management',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const HomeWidget(),
    );
  }
}

class CounterController extends MomentumController<CounterModel> {
  @override
  CounterModel init() {
    return CounterModel(
      this,
      value: 0,
    );
  }

  void increment() {
    model.update(value: model.value + 1);
  }
}

class CounterModel extends MomentumModel<CounterController> {
  const CounterModel(
    super.controller, {
    required this.value,
  });

  final int value;

  @override
  void update({int? value}) {
    CounterModel(
      controller,
      value: value ?? this.value,
    ).updateMomentum();
  }
}

class HomeWidget extends StatelessWidget {
  const HomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Momentum Counter'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You have pushed the button this many times:'),
            MomentumBuilder(
              controllers: const [CounterController],
              builder: (context, snapshot) {
                final counter = snapshot<CounterModel>();
                return Text(
                  '${counter.value}',
                  style: Theme.of(context).textTheme.headlineMedium,
                );
              },
            ),
          ],
        ),
      ),
      // We don't need to rebuild the button, so it can live outside MomentumBuilder.
      floatingActionButton: FloatingActionButton(
        onPressed: Momentum.controller<CounterController>(context).increment,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
