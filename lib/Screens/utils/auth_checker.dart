import 'package:buku/Screens/admin/root_screen.dart';
import 'package:buku/Screens/auth/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> checkTokenAndRedirect(BuildContext context) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  if (token != null) {
   // ignore: use_build_context_synchronously
   Navigator.push(
   context,
    MaterialPageRoute(builder: (context) =>const RootScreen()), 
                        );
  } else {
    // ignore: use_build_context_synchronously
    Navigator.push(
     context,
    MaterialPageRoute(builder: (context) =>const LoginScreen()), 
                        );
    
  }
}
