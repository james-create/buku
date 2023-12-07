import 'package:buku/Screens/auth/login_screen.dart';
import 'package:flutter/material.dart';

class PasswordResetSuccess extends StatefulWidget {
  const PasswordResetSuccess({super.key});

  @override
  State<PasswordResetSuccess> createState() => _PasswordResetSuccessState();
}

class _PasswordResetSuccessState extends State<PasswordResetSuccess> {
  @override
  Widget build(BuildContext context) {
    // access width and height
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
          
                Container(
                  width: w,
                  height: h * 0.3,
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                    image: AssetImage("images/login.png"),
                    // fit: BoxFit.cover,
                  )),
                ),
          
          
                SizedBox(
                  width: w * 0.9,
                  child: Column(children: [
                    const Text(
                      "Your password has been changed",
                      style: TextStyle(fontSize: 20,color: Colors.orange, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      "Use the new password to login",
                      style: TextStyle(fontSize: 20, color: Colors.green),
                    ),
          
                    const SizedBox(
                      height: 10,
                    ),
                  Image.network('https://media.tenor.com/mdaXzkXWw4sAAAAM/congratulations-congrats.gif'),

          
               Container(
                      width: w * 0.9,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                        child: const Center(
                          child:  Text(
                            'Login now ',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 34,
                              
                            ),
                          ),
                          
                        ),
                      ),
                    
                    ),
                  
          
                   
          
                  ]),
                )
              ],
            ),
          ),
        ));
  }
}
