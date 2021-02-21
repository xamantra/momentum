import 'package:shared_preferences/shared_preferences.dart';

SharedPreferences _sharedPreferences;
SharedPreferences get sharedPreferences => _sharedPreferences;

Future<void> initializeSharedPref() async {
  _sharedPreferences = await SharedPreferences.getInstance();
}
