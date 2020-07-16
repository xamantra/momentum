import 'package:momentum/momentum.dart';

import '../../widgets/inject_service.dart';
import 'index.dart';

class InjectServiceController extends MomentumController<InjectServiceModel> {
  @override
  InjectServiceModel init() {
    return InjectServiceModel(
      this,
    );
  }

  CalculatorService getServiceWithoutLogs() {
    return getService<CalculatorService>(alias: CalcAlias.disableLogs);
  }

  CalculatorService getServiceWithLogs() {
    return getService<CalculatorService>(alias: CalcAlias.enableLogs);
  }
}
