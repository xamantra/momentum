import 'package:momentum/momentum.dart';
import '../../services/api.service.dart';

import 'index.dart';

class AsynchronousController extends MomentumController<AsynchronousModel> {
  @override
  AsynchronousModel init() {
    return AsynchronousModel(
      this,
      loadingUser: false,
    );
  }

  void loadUser() async {
    model.update(loadingUser: true);
    var apiService = getService<ApiService>();
    var user = await apiService.getUser();
    model.update(loadingUser: false, user: user);
  }
}
