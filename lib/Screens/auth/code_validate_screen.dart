import 'dart:convert';

import 'package:buku/Screens/auth/password_reset_success.dart';
import 'package:buku/Screens/auth/login_screen.dart';
import 'package:buku/Screens/auth/reset_password_screen.dart';
import 'package:buku/Screens/utils/constarts.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CodeValidateScreen extends StatefulWidget {
  const CodeValidateScreen({super.key});

  @override
  State<CodeValidateScreen> createState() => _CodeValidateScreenState();
}

class _CodeValidateScreenState extends State<CodeValidateScreen> {
  final _codeController=TextEditingController();
  final _passwordController=TextEditingController();

  String code='';
  String password='';

  String message = '';

  String codeError = '';
   String passwordError = '';

  bool isLoading = false;




 void clearError() {
    setState(() {
      codeError = '';
      passwordError='';
      message='';
    });
  }


 

 
  Future<void> _validateCode() async {
      setState(() {
        isLoading = true; 
      });

      String apiUrl = "$appApiUrl/reset";
      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          body: {
            "token": code,
            "password": password,
          },
        );
        if (response.statusCode == 200) {
             Navigator.push(
             context,
             MaterialPageRoute(builder: (context) => const PasswordResetSuccess()),
            );
        }else if(response.statusCode==400)
        {
         final responseData = json.decode(response.body);
          if (responseData.containsKey('validation_errors')) {
            final validationErrors = responseData['validation_errors'];
            if (validationErrors.containsKey('token')) {
              codeError = validationErrors['token'][0]; // Assuming it's an array of error messages
            }
            if (validationErrors.containsKey('password')) {
              passwordError = validationErrors['password'][0]; // Assuming it's an array of error messages
            }
          }
          print(responseData);

        } 
        else if(response.statusCode==401)
        {
          final responseData = json.decode(response.body);
          // print(responseData);
          codeError = responseData['message']; 
          message='Invalid Code. Confirm or resend and try again';
        }
      } catch (error) {
        print(error);
      }finally {
        setState(() {
          isLoading = false; // Hide loading indicator
        });
    }
    }

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
                  height: h * 0.4,
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                    image: AssetImage("images/forget.png"),
                    // fit: BoxFit.cover,
                  )),
                ),
          
          
                   Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      message,
                      style: const TextStyle(color: Colors.green),
                    ),
                  ),
          
                  Center(
                  child: isLoading
                      ? const CircularProgressIndicator() // Show the spinner when isLoading is true
                      : const Text(''),     // Show "Content loaded" when isLoading is false
                  ),

                SizedBox(
                  width: w * 0.9,
                  child: Column(children: [
                    const Text(
                      "Validate your code",
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                      const Align(
                        // alignment: Alignment.center,
                        child: Center(
                          child: Text(
                          "Check your email, We have sent password request code to your email  ",
                          style: TextStyle(fontSize: 10, color: Colors.blue),
                                            ),
                        ),
                      ),
                    // const Text(
                    //   "Enter the code sent to your email below",
                    //   style: TextStyle(fontSize: 20, color: Colors.grey),
                    // ),
          
                    const SizedBox(
                      height: 10,
                    ),
                    TextField(
                        controller: _codeController,
                        onChanged: (value) {
                        clearError(); // Clear error message when content changes
                      },
                      decoration: InputDecoration(
                          hintText: "Enter code",
                          prefixIcon: const Icon(
                            Icons.token,
                            color: Colors.deepOrangeAccent,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                          )),
                    ),
                      Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      codeError,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                     TextField(
                      controller: _passwordController,
                      onChanged: (value) {
                        clearError(); // Clear error message when content changes
                      },
                      decoration: InputDecoration(
                          hintText: "Enter new password",
                          prefixIcon: const Icon(
                            Icons.password,
                            color: Colors.deepOrangeAccent,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                          )),
                    ),
                      Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      passwordError,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                    const SizedBox(
                      height: 10,
                    ),
             
                    const SizedBox(
                      height: 15,
                    ),
          
               
                SizedBox(
                width: double.infinity,
                child: MaterialButton(
                  onPressed: () {
                    setState(() {
                      code = _codeController.text;
                      password = _passwordController.text;
                    });
                    _validateCode(); // Your function here
                  },
                  color: Colors.blue,
                  textColor: Colors.white,
                  child: const Text('Change Password'),
                ),
              ),
                    const SizedBox(
                      height: 10,
                    ),
          
          
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Go back?'),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const LoginScreen()), 
                              );
                            },
                            child: const Text(
                              ' Login ',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
          
           const SizedBox(
                      height: 40,
                    ),
          
          
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('  Request another code?'),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const ResetPasswordScreen()), 
                              );
                            },
                            child: const Text(
                              ' Yes ',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
          
          
                  // const Row(
                  //   mainAxisAlignment: MainAxisAlignment.center,
                  //   children: [
                  //     Text('Forgot your account?'),
                  //     Text(' Reset Here',
                  //     style: TextStyle(
                  //       color: Colors.green,
                  //       fontWeight: FontWeight.bold,
                  //     ),),
                  //   ],
                  // )
          
          
                  ]),
                )
              ],
            ),
          ),
        ));
  }
}
