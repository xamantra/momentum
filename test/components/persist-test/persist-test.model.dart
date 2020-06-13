import 'package:momentum/momentum.dart';

import 'index.dart';

class PersistTestModel extends MomentumModel<PersistTestController> {
  PersistTestModel(
    PersistTestController controller, {
    this.username,
    this.email,
  }) : super(controller);

  final String username;
  final String email;

  @override
  void update({
    String username,
    String email,
  }) {
    PersistTestModel(
      controller,
      username: username ?? this.username,
      email: email ?? this.email,
    ).updateMomentum();
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
    };
  }

  PersistTestModel fromJson(Map<String, dynamic> map) {
    if (map == null) return null;

    return PersistTestModel(
      controller,
      username: map['username'],
      email: map['email'],
    );
  }
}
