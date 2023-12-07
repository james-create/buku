
import 'dart:convert';
import 'package:buku/Screens/admin/root_screen.dart';
import 'package:buku/Screens/auth/login_screen.dart';
import 'package:buku/Screens/utils/constarts.dart';
import 'package:buku/Screens/utils/show_custom_error_message.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {

 

  // get what the user typed
  final _nameController=TextEditingController();
  final _emailController=TextEditingController();
  final _passwordController=TextEditingController();
  final _passwordConfirmationController=TextEditingController();

  // stores what the user typed
  String name='';
  String username='';
  String email='';
  String password='';
  String passwordConfirmation='';
  
  // errors
  String nameError = '';
  String emailError = '';
  String passwordError = '';
  String passwordConfirmationError='';

  bool isLoading = false;


  bool _obscurePassword = true;
  bool _obscurePasswordConfirmation = true;
    


  Future<void> _registerUser() async {
       String apiUrl = "$appApiUrl/register";

      setState(() {
        isLoading = true; 
      });

      try {
        final response = await http.post(
          Uri.parse(apiUrl),
          body: {
            "name": name,
            "username": email,
            "email": email,
            "password": password,
            "password_confirmation": passwordConfirmation
          },
        );
        if (response.statusCode == 200) {
          final responseData = json.decode(response.body); // Parse the JSON response
          final token = responseData['token'];
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('token', token);
          // ignore: use_build_context_synchronously
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const RootScreen()));    
        } else if (response.statusCode == 400) {
           final responseData = json.decode(response.body);
          if (responseData.containsKey('validation_errors')) {
          final validationErrors = responseData['validation_errors'];
          if (validationErrors.containsKey('email')) {
            emailError = validationErrors['email'][0];
          }
          if (validationErrors.containsKey('password')) {
            passwordError = validationErrors['password'][0];
          }
          if (validationErrors.containsKey('name')) {
            nameError = validationErrors['name'][0];
          }
        }
        }
      } catch (error) {
        showCustomErrorMessage(context, 'Unexpected server error check your internet cconnection');
        print('Error: $error');
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
                    image: AssetImage("images/register.png"),
                    // fit: BoxFit.cover,
                  )),
                ),
                
                 
                SizedBox(
                  width: w * 0.9,
                  child: Column(children: [
                    const Text(
                      "Create Account!",
                      style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                    const Text(
                      "We are happy to have you onboard",
                      style: TextStyle(fontSize: 20, color: Colors.grey),
                    ),
                    
          
                    const SizedBox(
                      height: 5,
                    ),
          
                    TextField(
                      controller: _nameController,
                    onChanged: (value) {
                      setState(() {
                        name = value; // Update the name value variable with the current content
                        nameError = ''; // Clear the error message
                      });
                    },
                        decoration: InputDecoration(
                          hintText: "Name",
                          prefixIcon: const Icon(
                            Icons.person_3,
                            color: Colors.deepOrangeAccent,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5),
                          )),
                        ),
                          Align(
                             alignment: Alignment.centerLeft,
                            child: Text(
                              nameError,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        const SizedBox(
                          height: 5,
                        ),
          
              
                     TextField(
                      controller: _emailController,
                          onChanged: (value) {
                          setState(() {
                            email = value; // Update the email value variable with the current content
                            emailError = ''; // Clear the error message
                          });
                        },
                      decoration: InputDecoration(
                          hintText: "Email",
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
                      child: Text(emailError,style:const TextStyle(color: Colors.red),)),
                    const SizedBox(
                      height: 5,
                    ),

                    
                 TextField(
  controller: _passwordController,
  onChanged: (value) {
    setState(() {
      password = value;
      passwordError = '';
    });
  },
  obscureText: _obscurePassword,
  decoration: InputDecoration(
    hintText: "Password",
    prefixIcon: const Icon(
      Icons.lock,
      color: Colors.deepOrangeAccent,
    ),
    suffixIcon: GestureDetector(
      onTap: () {
        setState(() {
          _obscurePassword = !_obscurePassword;
        });
      },
      child: Icon(
        _obscurePassword ? Icons.visibility : Icons.visibility_off,
        color: Colors.deepOrangeAccent,
      ),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
    ),
  ),
),
Container(
  alignment: Alignment.centerLeft,
  child: Text(
    passwordError,
    style: const TextStyle(color: Colors.red),
  ),
),
const SizedBox(
  height: 10,
),

TextField(
  controller: _passwordConfirmationController,
  onChanged: (value) {
    setState(() {
      passwordConfirmation = value;
      passwordConfirmationError = '';
    });
  },
  obscureText: _obscurePasswordConfirmation,
  decoration: InputDecoration(
    hintText: "Password confirmation",
    prefixIcon: const Icon(
      Icons.lock,
      color: Colors.deepOrangeAccent,
    ),
    suffixIcon: GestureDetector(
      onTap: () {
        setState(() {
          _obscurePasswordConfirmation = !_obscurePasswordConfirmation;
        });
      },
      child: Icon(
        _obscurePasswordConfirmation ? Icons.visibility : Icons.visibility_off,
        color: Colors.deepOrangeAccent,
      ),
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(5),
    ),
  ),
),
                    const SizedBox(
                      height: 10,
                    ),
          
          
             // ............................................................
                    MaterialButton(
                      minWidth: h *0.9,
                      onPressed: () {
                        // Update the string variables
                        setState(() {
                          name = _nameController.text;
                          email = _emailController.text;
                          password = _passwordController.text;
                          passwordConfirmation = _passwordConfirmationController.text;
                        });
                        _registerUser(); // Call the _registerUser function here
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
                          'Sign up',
                          style: TextStyle(color: Colors.white),
                        ),
                    ),
                       // .................................................................
          
          
          
          
                    const SizedBox(
                      height: 20,
                    ),
          
          
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Already a member?'),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const LoginScreen()), 
                              );
                            },
                            child: const Text(
                              ' Login now',
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
