import 'package:example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Momentum Demo Test', (tester) async {
    await tester.pumpWidget(momentum());
    return;
  });
}
