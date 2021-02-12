import '../storage/index.dart';

Future<bool> persistSave_SharedPref(context, key, value) async {
  var result = await sharedPreferences.setString(key, value);
  return result;
}

Future<String> persistGet_SharedPref(context, key) async {
  var result = sharedPreferences.getString(key);
  return result;
}
