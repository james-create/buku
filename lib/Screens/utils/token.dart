import 'package:shared_preferences/shared_preferences.dart';

Future<String> getTokenFromSharedPreferences() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String storedToken = prefs.getString('token') ?? '';
  return storedToken;
}



