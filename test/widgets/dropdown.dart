import 'package:flutter/material.dart';
import 'package:momentum/momentum.dart';

import '../components/dropdown/index.dart';

const dropdownKey = Key('dropdownApp.dropdownKey');

Momentum dropdownApp() {
  return Momentum(
    child: _DropdownApp(),
    controllers: [
      DropdownController()..config(maxTimeTravelSteps: 5),
    ],
  );
}

class _DropdownApp extends StatelessWidget {
  const _DropdownApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dropdown App',
      home: Scaffold(
        body: Container(
          child: Center(
            child: MomentumBuilder(
              controllers: [DropdownController],
              builder: (context, snapshot) {
                var dropdownModel = snapshot<DropdownModel>();
                return Column(
                  children: <Widget>[
                    Text('Selected: ${dropdownModel.gender}'),
                    DropdownButton<Gender>(
                      key: dropdownKey,
                      value: dropdownModel.gender,
                      items: Gender.values
                          .map<DropdownMenuItem<Gender>>(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(
                                e.toString(),
                                key: Key('$e'),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        Momentum.controller<DropdownController>(
                          context,
                        ).changeGender(value);
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
