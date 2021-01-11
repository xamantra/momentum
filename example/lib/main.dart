import 'package:flutter/material.dart';
import 'package:momentum/momentum.dart';

import 'src/components/rest-api-example/index.dart';
import 'src/components/timer-example/index.dart';
import 'src/services/index.dart';
import 'src/widgets/pages/home/index.dart';

void main() {
  runApp(momentum());
}

Momentum momentum() {
  return Momentum(
    child: MyApp(),
    controllers: [
      TimerExampleController(),
      RestApiExampleController(),
    ],
    services: [
      ApiService(),
    ],
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Momentum Flutter Demo',
      theme: ThemeData(
        primaryColor: Colors.purple,
        accentColor: Colors.pink,
        colorScheme: ColorScheme.dark(
          primary: Colors.purple,
          onPrimary: Colors.white,
          secondary: Colors.pink,
          onSecondary: Colors.white,
        ),
        backgroundColor: Color(0xff222222),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
