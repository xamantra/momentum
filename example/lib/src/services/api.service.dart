import 'package:momentum/momentum.dart';

class ApiService extends MomentumService {
  Future<User> getUser() async {
    await Future.delayed(Duration(milliseconds: 3000));
    var result = User(username: 'johndoe', email: 'john@doe.com');
    return result;
  }
}

class User {
  final String username;
  final String email;

  User({this.username, this.email});
}
