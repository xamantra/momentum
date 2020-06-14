import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../components/dropdown/index.dart';
import '../utilities/launcher.dart';
import '../widgets/dropdown.dart';

void main() {
  testWidgets('Dropdown test', (tester) async {
    var widget = dropdownApp();
    await launch(tester, widget);

    var controller = widget.getController<DropdownController>();
    expect(controller, isInstanceOf<DropdownController>());
    await tester.tap(find.byKey(dropdownKey));
    await tester.pumpAndSettle();
    var selected = (List<Gender>.from(Gender.values)..shuffle()).last;
    await tester.tap(find.byKey(Key('$selected')).last);
    await tester.pumpAndSettle();
    expect(find.text('Selected: $selected'), findsOneWidget);
    expect(controller.model.gender, selected);
    controller.backward();
    await tester.pumpAndSettle();
    expect(find.text('Selected: ${Gender.other}'), findsOneWidget);
    expect(controller.model.gender, Gender.other);
  });
}
