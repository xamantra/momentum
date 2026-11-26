import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:momentum/momentum.dart';

class _TestModel extends MomentumModel<_TestController> {
  final int count;
  final bool returnNullToJson;
  final bool throwOnToJson;
  final void Function(Map<String, dynamic>?)? onFromJson;

  const _TestModel(
    _TestController controller, {
    this.count = 0,
    this.returnNullToJson = false,
    this.throwOnToJson = false,
    this.onFromJson,
  }) : super(controller);

  @override
  void update({int? count}) {
    _TestModel(
      controller,
      count: count ?? this.count,
      returnNullToJson: returnNullToJson,
      throwOnToJson: throwOnToJson,
      onFromJson: onFromJson,
    ).updateMomentum();
  }

  @override
  Map<String, dynamic>? toJson() {
    if (throwOnToJson) {
      throw Exception('toJson failed');
    }
    if (returnNullToJson) {
      return null;
    }
    return {'count': count};
  }

  @override
  _TestModel? fromJson(Map<String, dynamic>? json) {
    onFromJson?.call(json);
    if (json == null) return null;
    return _TestModel(
      controller,
      count: json['count'] as int? ?? 0,
      returnNullToJson: returnNullToJson,
      throwOnToJson: throwOnToJson,
      onFromJson: onFromJson,
    );
  }
}

class _TestController extends MomentumController<_TestModel> {
  final bool returnNullToJson;
  final bool throwOnToJson;
  final void Function(Map<String, dynamic>?)? onFromJson;

  _TestController({
    this.returnNullToJson = false,
    this.throwOnToJson = false,
    this.onFromJson,
  });

  @override
  _TestModel init() => _TestModel(
        this,
        returnNullToJson: returnNullToJson,
        throwOnToJson: throwOnToJson,
        onFromJson: onFromJson,
      );
}

class _MissingService extends MomentumService {}

class _InitStateProbe extends StatefulWidget {
  final void Function(_TestController) onInit;
  const _InitStateProbe({required this.onInit});

  @override
  State<_InitStateProbe> createState() => _InitStateProbeState();
}

class _InitStateProbeState extends State<_InitStateProbe> {
  @override
  void initState() {
    super.initState();
    widget.onInit(Momentum.controller<_TestController>(context));
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

void main() {
  group('Ticket fixes', () {
    testWidgets('Momentum.controller throws MomentumError when no Momentum ancestor exists', (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              capturedContext = context;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(
        () => Momentum.controller<_TestController>(capturedContext),
        throwsA(isA<MomentumError>()),
      );
    });

    testWidgets('Momentum.controller works inside initState without dependOnInheritedWidget error', (tester) async {
      _TestController? resolved;
      final controller = _TestController();
      await tester.pumpWidget(
        Momentum(
          controllers: [controller],
          child: MaterialApp(
            home: _InitStateProbe(onInit: (c) => resolved = c),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(resolved, same(controller));
    });

    test('Persistence does not save null/throw and does not call fromJson when nothing persisted', () async {
      final savedValues = <String?>[];
      final fromJsonCalls = <Map<String, dynamic>?>[];

      final nullToJsonController = _TestController(
        returnNullToJson: true,
        onFromJson: fromJsonCalls.add,
      );
      final tester1 = MomentumTester(
        Momentum(
          controllers: [nullToJsonController],
          persistSave: (context, key, value) async {
            savedValues.add(value);
            return true;
          },
          persistGet: (context, key) async => null,
        ),
      );
      await tester1.init();
      nullToJsonController.model.update(count: 1);
      await tester1.init();

      expect(fromJsonCalls, isEmpty);
      expect(savedValues, isEmpty);

      final throwingController = _TestController(throwOnToJson: true);
      final tester2 = MomentumTester(
        Momentum(
          controllers: [throwingController],
          persistSave: (context, key, value) async {
            savedValues.add(value);
            return true;
          },
          persistGet: (context, key) async => '',
        ),
      );
      await tester2.init();
      throwingController.model.update(count: 2);

      expect(savedValues, isEmpty);
    });

    testWidgets('Momentum.restart throws MomentumError when momentum and restartCallback are both null', (tester) async {
      late BuildContext capturedContext;
      await tester.pumpWidget(
        Momentum(
          controllers: [_TestController()],
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                capturedContext = context;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        () => Momentum.restart(capturedContext),
        throwsA(isA<MomentumError>()),
      );
    });

    testWidgets('Momentum.resetAll forwards clearHistory through onResetAll', (tester) async {
      final controller = _TestController();
      late BuildContext capturedContext;
      await tester.pumpWidget(
        Momentum(
          maxTimeTravelSteps: 5,
          controllers: [controller],
          onResetAll: (context, resetAll) => resetAll(context),
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                capturedContext = context;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      controller.model.update(count: 1);
      controller.model.update(count: 2);
      expect(controller.prevModel?.count, 1);

      Momentum.resetAll(capturedContext, clearHistory: true);
      expect(controller.model.count, 0);
      expect(controller.prevModel, isNull);
    });

    test('service error message references service<T>()', () async {
      final controller = _TestController();
      final tester = MomentumTester(Momentum(controllers: [controller]));
      await tester.init();

      expect(
        () => controller.service<_MissingService>(),
        throwsA(
          isA<MomentumError>().having(
            (e) => e.toString(),
            'toString()',
            contains('service<_MissingService>()'),
          ),
        ),
      );
    });

    test('controller error messages reference controller<T>()', () async {
      final controller = _TestController();
      final tester = MomentumTester(Momentum(controllers: [controller]));
      await tester.init();

      expect(
        () => controller.controller<_TestController>(),
        throwsA(
          isA<MomentumError>().having(
            (e) => e.toString(),
            'toString()',
            contains('controller<_TestController>()'),
          ),
        ),
      );
    });

    testWidgets('public API exports MomentumError and all momentum_types typedefs', (tester) async {
      final controller = _TestController();
      var saved = <String, String?>{};
      var resetCalled = false;

      final PersistSaver saver = (context, key, value) async {
        saved[key] = value;
        return true;
      };
      final PersistGet getter = (context, key) async => saved[key];
      final ResetAll onResetAll = (context, resetAll) {
        resetCalled = true;
        resetAll(context);
      };
      final BuildSkipper skipper = (ctrl, isTimeTravel) => false;
      Widget renderSnapshot(MomentumSnapshot snapshot) {
        final model = snapshot<_TestModel>();
        return Text('count:${model.count}');
      }
      final MomentumBuilderFunction builder = (context, snapshot) => renderSnapshot(snapshot);

      late BuildContext capturedContext;
      await tester.pumpWidget(
        Momentum(
          controllers: [controller],
          persistSave: saver,
          persistGet: getter,
          onResetAll: onResetAll,
          child: MaterialApp(
            home: Builder(
              builder: (context) {
                capturedContext = context;
                return MomentumBuilder(
                  controllers: [_TestController],
                  dontRebuildIf: skipper,
                  builder: builder,
                );
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('count:0'), findsOneWidget);
      controller.model.update(count: 42);
      await tester.pumpAndSettle();
      expect(find.text('count:42'), findsOneWidget);

      Momentum.resetAll(capturedContext);
      await tester.pumpAndSettle();
      expect(resetCalled, isTrue);
      expect(find.text('count:0'), findsOneWidget);
      expect(const MomentumError('boom').toString(), 'MomentumError: boom');
    });
  });
}
