import 'dart:convert';
import 'package:buku/Screens/admin/root_screen.dart';
import 'package:buku/Screens/auth/register_screen.dart';
import 'package:buku/Screens/auth/reset_password_screen.dart';
import 'package:buku/Screens/auth/welcome_screen.dart';
import 'package:buku/Screens/utils/constarts.dart';
import 'package:buku/Screens/utils/custom_snacable.dart';
import 'package:buku/Screens/utils/show_custom_error_message.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

 
    // get what the user typed
  final _usernameController=TextEditingController();
  final _passwordController=TextEditingController();

  // stores what the user typed
  String username='';
  String password='';

  // errors
  String message = '';
  String usernameError = '';
  String passwordError = '';

  // api call 
  bool isLoading = false;
  bool _passwordVisible = false; // Track the visibility of the password

 Future<void> _signIn() async {
  setState(() {
    isLoading = true;
  });
  String apiUrl = "$appApiUrl/login";
  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      body: {
        "username": username,
        "password": password,
      },
    );
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final token = responseData['token'];
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const RootScreen()));
    } else if (response.statusCode == 400) {
      final validationErrors = json.decode(response.body);
      usernameError = validationErrors['validation_errors']['username'][0] ?? '';
      passwordError = validationErrors['validation_errors']['password'][0] ?? '';
    } else if (response.statusCode == 401) {
      // Unauthorized error, handle it as needed
      showCustomErrorMessage(context, 'Unauthorized: Invalid username or password');
    } else {
      // Handle other HTTP status codes here if necessary
      showCustomErrorMessage(context, 'Unexpected server error');
    }
  } catch (error) {
    // Handle connection errors or other exceptions here
    ApiResponse.showSnackBar(context, 'Network error. Check your internet connection.');
  } finally {
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
                    image: AssetImage("images/login.png"),
                    // fit: BoxFit.cover,
                  )),
                ),
          
                SizedBox(
                  width: w * 0.9,
                  child: Column(children: [
               const Text(
                "Welcome Back!",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
              ),
              const Text(
                "Glad to see you again. You've been missed!",
                style: TextStyle(fontSize: 15, color: Colors.grey),
              ),

                     const SizedBox(height: 10,),
                    TextField(
                      controller: _usernameController,
                      onChanged: (value) {
                          setState(() {
                            username = value; // Update the passwoord value variable with the current content
                            usernameError = ''; // Clear the error message
                          });
                      },
                      decoration: InputDecoration(
                          hintText: "Username or email",
                          prefixIcon: const Icon(
                            Icons.mark_email_read_sharp,
                            color: Colors.deepOrangeAccent,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                          )),
                    ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      usernameError,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),

                  
                  

                  TextField(
                    controller: _passwordController,
                    onChanged: (value) {
                      setState(() {
                        password = value;
                        passwordError = '';
                      });
                    },
                    obscureText: !_passwordVisible, // Toggle between obscured and visible text
                    decoration: InputDecoration(
                      hintText: "Password",
                      prefixIcon: const Icon(
                        Icons.password_sharp,
                        color: Colors.deepOrangeAccent,
                      ),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible; // Toggle the password visibility
                          });
                        },
                        icon: Icon(
                          _passwordVisible ? Icons.visibility : Icons.visibility_off,
                          color: Colors.deepOrangeAccent,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),

                

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      passwordError,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),

               Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Text(''),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ResetPasswordScreen()), 
                      );
                    },
                    child: const Text(
                      'Forgot your account?',
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
                   
              MaterialButton(
                minWidth: h * 0.9,
                onPressed: () {
                  // Update the string variables
                  setState(() {
                    username = _usernameController.text;
                    password = _passwordController.text;
                  });
                  _signIn(); // Call the _signIn function here
                },
                color: Colors.blue,
                  child: isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 16, // Adjust this value to control the size
                              height: 16, // Adjust this value to control the size
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 10), // Add some spacing between the spinner and text
                            Text(
                              'Loading...',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        )
                      : const Text(
                          'Sign in',
                          style: TextStyle(color: Colors.white),
                        ),
              ),

          
                    const SizedBox(
                      height: 10,
                    ),
          
          
                  Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Not a member?'),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>const RegisterScreen()), 
                        );
                      },
                      child: const Text(
                        ' Register now',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
          
          
                    const SizedBox(
                      height: 10,
                    ),
          
       
          
              const SizedBox(height: 150),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Go back?'),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const WelcomeScreen()), 
                      );
                    },
                    child: const Text(
                      ' Click Here',
                      style: TextStyle(
                        color: Colors.red,
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
