import 'package:flutter_test/flutter_test.dart';
import 'package:momentum/momentum.dart';
import 'package:momentum/src/momentum_base.dart';
import 'package:momentum/src/momentum_error.dart';

import '../../demo_app/src/services/index.dart';

void main() {
  test('<MomentumService> test', () async {
    var tester = MomentumTester(
      Momentum(
        controllers: [],
        services: [
          InjectService('A', ApiService('A')),
          InjectService('B', DummyService()),
          InjectService('C', ApiService('C')),
        ],
      ),
    );
    await tester.init();

    var api = tester.service<ApiService>(alias: 'A');
    expect(api != null, true);
    expect(api, isInstanceOf<ApiService>());
    expect(api.id, 'A');

    var dummy = tester.service<DummyService>(alias: 'B');
    expect(dummy != null, true);
    expect(dummy, isInstanceOf<DummyService>());

    InjectService<ApiService> injected;
    injected = tester.service<InjectService<ApiService>>();
    expect(injected != null, true);
    expect(injected.value.id, 'A'); // If alias isn't provided, the first occurence gets returned.

    InjectService<ApiService> injectedC;
    injectedC = tester.service<InjectService<ApiService>>(alias: 'C');
    expect(injectedC != null, true);
    expect(injectedC.value.id, 'C');

    ApiService injectedWithAlias;
    injectedWithAlias = tester.service<ApiService>(alias: 'C');
    expect(injectedWithAlias != null, true);
    expect(injectedWithAlias.id, 'C');
  });

  test('<MomentumService> error test', () async {
    var tester = MomentumTester(
      Momentum(
        controllers: [],
        services: [
          InjectService('A', ApiService()),
          InjectService('B', DummyService()),
        ],
      ),
    );
    await tester.init();

    ApiService api;
    trycatch(() {
      api = tester.service<ApiService>(alias: 'B');
    });
    expect(api == null, true);

    DummyService dummy;
    trycatch(() {
      dummy = tester.service<DummyService>(alias: 'A');
    });
    expect(dummy == null, true);

    InjectService<ApiService> injected;
    trycatch(() {
      injected = tester.service<InjectService>();
    });
    expect(injected == null, true);

    InjectService<dynamic> injectedDynamic;
    trycatch(() {
      injectedDynamic = tester.service<InjectService<dynamic>>();
    });
    expect(injectedDynamic == null, true);
  });

  group('test services group', () {
    test('test inject service with error', () async {
      var tester = MomentumTester(
        Momentum(
          controllers: [],
          services: [
            InjectService('srv1', ApiService()),
          ],
        ),
      );
      await tester.init();

      try {
        tester.service<InjectService>();
        expect(1, 0); // force fail test. must throw an error to pass
      } catch (e) {
        expect(e, isInstanceOf<MomentumError>());
      }

      var tester2 = MomentumTester(
        Momentum(
          controllers: [],
          services: [
            InjectService('srv1', ApiService()),
          ],
        ),
      );
      await tester2.init();

      try {
        tester2.service<InjectService<dynamic>>();
        expect(1, 0); // force fail test. must throw an error to pass
      } catch (e) {
        expect(e, isInstanceOf<MomentumError>());
      }
    });

    test('test inject service (targeted type)', () async {
      var tester = MomentumTester(
        Momentum(
          controllers: [],
          services: [
            InjectService('srv1', ApiService()),
            DummyService(),
          ],
        ),
      );
      await tester.init();

      var apiService = tester.service<ApiService>();
      var dummyService = tester.service<DummyService>();

      expect(apiService != null, true);
      expect(dummyService != null, true);
    });

    test('test inject service error (targeted type)', () async {
      var tester = MomentumTester(
        Momentum(
          controllers: [],
          services: [
            InjectService('srv1', DummyService()),
            DummyService(),
          ],
        ),
      );
      await tester.init();

      var dummyService = tester.service<DummyService>();
      expect(dummyService != null, true);

      try {
        tester.service<InjectService<ApiService>>(alias: 'srv1');
        expect(0, 1);
      } catch (e) {
        expect(e, isInstanceOf<MomentumError>());
      }
    });
  });
}
