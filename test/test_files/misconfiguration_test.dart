import 'dart:convert';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/momentum.dart';

import '../demo_app/components/dummy/index.dart';

class _PersistModel extends MomentumModel<_PersistController> {
  final int value;
  final void Function(Map<String, dynamic>?)? onFromJson;

  const _PersistModel(
    _PersistController controller, {
    required this.value,
    this.onFromJson,
  }) : super(controller);

  @override
  void update({int? value}) {
    _PersistModel(
      controller,
      value: value ?? this.value,
      onFromJson: onFromJson,
    ).updateMomentum();
  }

  @override
  Map<String, dynamic>? toJson() => {'value': value};

  @override
  _PersistModel? fromJson(Map<String, dynamic>? json) {
    onFromJson?.call(json);
    if (json == null) return null;
    return _PersistModel(
      controller,
      value: json['value'] as int? ?? 0,
      onFromJson: onFromJson,
    );
  }
}

class _PersistController extends MomentumController<_PersistModel> {
  final Future<bool?> Function()? skipPersistHandler;
  final void Function(Map<String, dynamic>?)? onFromJson;

  _PersistController({
    this.skipPersistHandler,
    this.onFromJson,
  });

  @override
  _PersistModel init() => _PersistModel(
        this,
        value: 0,
        onFromJson: onFromJson,
      );

  @override
  Future<bool?> skipPersist() async {
    if (skipPersistHandler != null) {
      return skipPersistHandler!();
    }
    return super.skipPersist();
  }
}

void main() {
  testWidgets('misconfigured json serializers.', (tester) async {
    var dummyController = DummyController();
    await tester.pumpWidget(_root(dummyController));
    await tester.pumpAndSettle();

    dummyController.model.update(value: 4);
    expect(dummyController.model.value, 4);
  });

  group('skipPersist() overriding disabledPersistentState', () {
    testWidgets('skipPersist() returning true skips get and save even when disabledPersistentState is false', (tester) async {
      final storage = <String, String?>{};
      var getCalls = 0;
      var saveCalls = 0;
      final controller = _PersistController(
        skipPersistHandler: () async => true,
      );
      storage[controller.persistenceKey] = jsonEncode({'value': 42});

      await tester.pumpWidget(
        Momentum(
          key: UniqueKey(),
          disabledPersistentState: false,
          controllers: [controller],
          persistGet: (context, key) async {
            getCalls++;
            return storage[key];
          },
          persistSave: (context, key, value) async {
            saveCalls++;
            storage[key] = value;
            return true;
          },
          child: const MaterialApp(home: Scaffold()),
        ),
      );
      await tester.pumpAndSettle();

      expect(controller.persistentStateDisabled, isFalse);
      expect(getCalls, 0);
      expect(controller.model.value, 0);

      controller.model.update(value: 99);
      await tester.pumpAndSettle();

      expect(controller.model.value, 99);
      expect(saveCalls, 0);
      expect(storage[controller.persistenceKey], jsonEncode({'value': 42}));
    });

    testWidgets('skipPersist() returning false enables get and save even when disabledPersistentState is true', (tester) async {
      final storage = <String, String?>{};
      var getCalls = 0;
      var saveCalls = 0;
      final controller = _PersistController(
        skipPersistHandler: () async => false,
      );
      storage[controller.persistenceKey] = jsonEncode({'value': 42});

      await tester.pumpWidget(
        Momentum(
          key: UniqueKey(),
          disabledPersistentState: true,
          controllers: [controller],
          persistGet: (context, key) async {
            getCalls++;
            return storage[key];
          },
          persistSave: (context, key, value) async {
            saveCalls++;
            storage[key] = value;
            return true;
          },
          child: const MaterialApp(home: Scaffold()),
        ),
      );
      await tester.pumpAndSettle();

      expect(controller.persistentStateDisabled, isTrue);
      expect(getCalls, 1);
      expect(controller.model.value, 42);

      controller.model.update(value: 77);
      await tester.pumpAndSettle();

      expect(controller.model.value, 77);
      expect(saveCalls, 1);
      expect(storage[controller.persistenceKey], jsonEncode({'value': 77}));
    });

    test('skipPersist() overrides disabledPersistentState in MomentumTester as well', () async {
      // skipPersist() == true with disabledPersistentState: false
      final storageA = <String, String?>{};
      var getCallsA = 0;
      var saveCallsA = 0;
      final ctrlA = _PersistController(skipPersistHandler: () async => true);
      storageA[ctrlA.persistenceKey] = jsonEncode({'value': 10});

      final testerA = MomentumTester(
        Momentum(
          disabledPersistentState: false,
          controllers: [ctrlA],
          persistGet: (context, key) async {
            getCallsA++;
            return storageA[key];
          },
          persistSave: (context, key, value) async {
            saveCallsA++;
            storageA[key] = value;
            return true;
          },
        ),
      );
      await testerA.init();
      expect(getCallsA, 0);
      expect(ctrlA.model.value, 0);

      ctrlA.model.update(value: 11);
      await Future<void>.delayed(Duration.zero);
      expect(saveCallsA, 0);

      // skipPersist() == false with disabledPersistentState: true
      final storageB = <String, String?>{};
      var getCallsB = 0;
      var saveCallsB = 0;
      final ctrlB = _PersistController(skipPersistHandler: () async => false);
      storageB[ctrlB.persistenceKey] = jsonEncode({'value': 25});

      final testerB = MomentumTester(
        Momentum(
          disabledPersistentState: true,
          controllers: [ctrlB],
          persistGet: (context, key) async {
            getCallsB++;
            return storageB[key];
          },
          persistSave: (context, key, value) async {
            saveCallsB++;
            storageB[key] = value;
            return true;
          },
        ),
      );
      await testerB.init();
      expect(getCallsB, 1);
      expect(ctrlB.model.value, 25);

      ctrlB.model.update(value: 30);
      await Future<void>.delayed(Duration.zero);
      expect(saveCallsB, 1);
      expect(storageB[ctrlB.persistenceKey], jsonEncode({'value': 30}));

      // skipPersist() == null defers to disabledPersistentState
      var getCallsC = 0;
      var saveCallsC = 0;
      final ctrlC = _PersistController();
      final testerC = MomentumTester(
        Momentum(
          disabledPersistentState: true,
          controllers: [ctrlC],
          persistGet: (context, key) async {
            getCallsC++;
            return jsonEncode({'value': 99});
          },
          persistSave: (context, key, value) async {
            saveCallsC++;
            return true;
          },
        ),
      );
      await testerC.init();
      ctrlC.model.update(value: 5);
      await Future<void>.delayed(Duration.zero);
      expect(getCallsC, 0);
      expect(saveCallsC, 0);
      expect(ctrlC.model.value, 5);
    });
  });

  group('partial persistence configuration (only persistSave or only persistGet)', () {
    testWidgets('providing only persistSave disables persistence cleanly in widget tree', (tester) async {
      var saveCalls = 0;
      final controller = _PersistController();

      await tester.pumpWidget(
        Momentum(
          key: UniqueKey(),
          controllers: [controller],
          persistSave: (context, key, value) async {
            saveCalls++;
            return true;
          },
          child: const MaterialApp(home: Scaffold()),
        ),
      );
      await tester.pumpAndSettle();

      controller.model.update(value: 15);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(controller.model.value, 15);
      expect(saveCalls, 0);
    });

    testWidgets('providing only persistGet disables persistence cleanly in widget tree', (tester) async {
      var getCalls = 0;
      final fromJsonCalls = <Map<String, dynamic>?>[];
      final controller = _PersistController(onFromJson: fromJsonCalls.add);

      await tester.pumpWidget(
        Momentum(
          key: UniqueKey(),
          controllers: [controller],
          persistGet: (context, key) async {
            getCalls++;
            return jsonEncode({'value': 42});
          },
          child: const MaterialApp(home: Scaffold()),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(getCalls, 0);
      expect(fromJsonCalls, isEmpty);
      expect(controller.model.value, 0);

      controller.model.update(value: 22);
      await tester.pumpAndSettle();
      expect(controller.model.value, 22);
    });

    test('providing only persistSave or only persistGet disables persistence in MomentumTester', () async {
      var saveCalls = 0;
      final ctrlSaveOnly = _PersistController();
      final testerSaveOnly = MomentumTester(
        Momentum(
          controllers: [ctrlSaveOnly],
          persistSave: (context, key, value) async {
            saveCalls++;
            return true;
          },
        ),
      );
      await testerSaveOnly.init();
      ctrlSaveOnly.model.update(value: 12);
      await Future<void>.delayed(Duration.zero);
      expect(ctrlSaveOnly.model.value, 12);
      expect(saveCalls, 0);

      var getCalls = 0;
      final ctrlGetOnly = _PersistController();
      final testerGetOnly = MomentumTester(
        Momentum(
          controllers: [ctrlGetOnly],
          persistGet: (context, key) async {
            getCalls++;
            return jsonEncode({'value': 88});
          },
        ),
      );
      await testerGetOnly.init();
      expect(getCalls, 0);
      expect(ctrlGetOnly.model.value, 0);
    });
  });

  group('graceful fallback on corrupted or non-Map JSON from persistGet', () {
    testWidgets('falls back to init() model on corrupted, non-Map, empty, or null JSON in widget tree', (tester) async {
      const invalidPayloads = <String?>[
        '{not valid json',
        'corrupted-string',
        '[1, 2',
        '[1, 2, 3]',
        '"just a json string"',
        '12345',
        'true',
        'null',
        '',
        null,
      ];

      for (final payload in invalidPayloads) {
        final fromJsonCalls = <Map<String, dynamic>?>[];
        final saved = <String?>[];
        final controller = _PersistController(onFromJson: fromJsonCalls.add);

        await tester.pumpWidget(
          Momentum(
            key: UniqueKey(),
            controllers: [controller],
            persistGet: (context, key) async => payload,
            persistSave: (context, key, value) async {
              saved.add(value);
              return true;
            },
            child: const MaterialApp(home: Scaffold()),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull, reason: 'payload=$payload');
        expect(fromJsonCalls, isEmpty, reason: 'payload=$payload');
        expect(controller.model.value, 0, reason: 'payload=$payload');

        // Updating and saving still works normally after fallback.
        controller.model.update(value: 7);
        await tester.pumpAndSettle();
        expect(controller.model.value, 7, reason: 'payload=$payload');
        expect(
            saved,
            [
              jsonEncode({'value': 7})
            ],
            reason: 'payload=$payload');
      }
    });

    testWidgets('falls back gracefully when persistGet throws an exception', (tester) async {
      final fromJsonCalls = <Map<String, dynamic>?>[];
      final controller = _PersistController(onFromJson: fromJsonCalls.add);

      await tester.pumpWidget(
        Momentum(
          key: UniqueKey(),
          controllers: [controller],
          persistGet: (context, key) async => throw StateError('storage read failure'),
          persistSave: (context, key, value) async => true,
          child: const MaterialApp(home: Scaffold()),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(fromJsonCalls, isEmpty);
      expect(controller.model.value, 0);
    });

    test('falls back to init() model on corrupted/non-Map JSON and throwing persistGet in MomentumTester', () async {
      for (final payload in ['{bad', '[1, 2]', '"str"', '42', 'false', 'null']) {
        final fromJsonCalls = <Map<String, dynamic>?>[];
        final controller = _PersistController(onFromJson: fromJsonCalls.add);
        final tester = MomentumTester(
          Momentum(
            controllers: [controller],
            persistGet: (context, key) async => payload,
            persistSave: (context, key, value) async => true,
          ),
        );
        await tester.init();

        expect(fromJsonCalls, isEmpty, reason: 'payload=$payload');
        expect(controller.model.value, 0, reason: 'payload=$payload');
      }

      final fromJsonCalls = <Map<String, dynamic>?>[];
      final throwingCtrl = _PersistController(onFromJson: fromJsonCalls.add);
      final tester = MomentumTester(
        Momentum(
          controllers: [throwingCtrl],
          persistGet: (context, key) async => throw Exception('read error'),
          persistSave: (context, key, value) async => true,
        ),
      );
      await tester.init();
      expect(fromJsonCalls, isEmpty);
      expect(throwingCtrl.model.value, 0);
    });
  });
}

Momentum _root(DummyController dummyController) {
  return Momentum(
    child: MaterialApp(home: Scaffold()),
    controllers: [dummyController],
    enableLogging: true,
    persistSave: (context, key, value) async {
      expect(value, null);
      return true;
    },
    persistGet: (context, key) async {
      return '{}';
    },
  );
}
