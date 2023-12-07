
import 'package:buku/Screens/auth/splash_screen.dart';
import 'package:flutter/material.dart';
void main() {
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      title: 'LearnStar',      
      debugShowCheckedModeBanner: false, 
      home:  const SplashScreen()
    );
  }
}






