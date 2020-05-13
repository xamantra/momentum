import 'package:momentum/momentum.dart';
import '../../services/api.service.dart';

import 'index.dart';

class AsynchronousModel extends MomentumModel<AsynchronousController> {
  AsynchronousModel(
    AsynchronousController controller, {
    this.user,
    this.loadingUser,
  }) : super(controller);

  final User user;
  final bool loadingUser;

  @override
  void update({
    User user,
    bool loadingUser,
  }) {
    AsynchronousModel(
      controller,
      user: user ?? this.user,
      loadingUser: loadingUser ?? this.loadingUser,
    ).updateMomentum();
  }
}
