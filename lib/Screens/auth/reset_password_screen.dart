import 'dart:convert';

import 'package:buku/Screens/auth/code_validate_screen.dart';
import 'package:buku/Screens/auth/login_screen.dart';
import 'package:buku/Screens/utils/constarts.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {

    // get what the user typed
  final _emailController=TextEditingController();
  // stores what the user typed
  String email='';
  // errors
  String message = '';
  String emailError = '';

  bool isLoading = false;
// clear errors 
 void clearError() {
    setState(() {
      emailError = '';
      message='';
    });
  }

 

 
  Future<void> _requestPasswordReset() async {
      setState(() {
        isLoading = true; 
      });

      String apiUrl = "$appApiUrl/password/reset";
      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          body: {
            "email": email,
            
          },
        );
        if (response.statusCode == 200) {
          final responseData = json.decode(response.body); // Parse the JSON response
          message = responseData['message'];
           Navigator.push(
           context,
           MaterialPageRoute(builder: (context) => const CodeValidateScreen()),
            );
            // print(response.body);
        }else if(response.statusCode==400)
        {
           final validationErrors = json.decode(response.body);
           emailError = validationErrors['validation_errors']['email'][0] ?? '';
          //  print(validationErrors);
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
                  height: h * 0.3,
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
                      "Forgot your password?",
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      "Request password reset below",
                      style: TextStyle(fontSize: 20, color: Colors.grey),
                    ),
          
                    const SizedBox(
                      height: 10,
                    ),
                    TextField(
                      controller: _emailController,
                      onChanged: (value) {
                        clearError(); // Clear error message when content changes
                      },
                      decoration: InputDecoration(
                          hintText: "Registered Email",
                          prefixIcon: const Icon(
                            Icons.email,
                            color: Colors.deepOrangeAccent,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                          )),
                    ),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      emailError,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                    const SizedBox(
                      height: 10,
                    ),
             
                  
                  
          
                SizedBox(
                width: double.infinity,
                child: MaterialButton(
                  onPressed: () {
                    setState(() {
                      email = _emailController.text;
                    });
                    print(email);
                    _requestPasswordReset(); // Your function here
                  },
                  color: Colors.blue,
                  textColor: Colors.white,
                  child: const Text('Request Password reset code'),
                ),
              ),

                    const SizedBox(
                      height: 20,
                    ),
          
          
                  
          
          
                        Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Already received the code?'),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const CodeValidateScreen()), 
                              );
                            },
                            child: const Text(
                              ' Validate it here',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
          
                
          
                
                    const SizedBox(
                      height: 20,
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
          
          
          
          
                  ]),
                )
              ],
            ),
          ),
        ));
  }
}
