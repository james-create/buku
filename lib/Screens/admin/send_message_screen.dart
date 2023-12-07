import 'dart:convert';

import 'package:buku/Screens/utils/constarts.dart';
import 'package:buku/Screens/utils/show_custom_error_message.dart';
import 'package:buku/Screens/utils/token.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class SendMessageScreen extends StatefulWidget {
  const SendMessageScreen({super.key});
  @override
  State<SendMessageScreen> createState() => _SendMessageScreenState();
}

class _SendMessageScreenState extends State<SendMessageScreen> {
// launching external url
final Uri _url = Uri.parse('https://wa.me/254706537241');
Future<void> _launchUrl() async {
  if (!await launchUrl(_url)) {
    throw Exception('Could not launch $_url');
  }
}

   // get what the user typed
  final _subjectController=TextEditingController();
  final _phoneController=TextEditingController();
  final _messageController=TextEditingController();
  // stores what the user typed
  String subject='';
  String phone='';
  String message='';

  // errors
  String subjectError = '';
  String phoneError = '';
  String messageError = '';
  // api call 
  bool isLoading = false;

   String token = '';


  Future<void> _loadToken() async {
    setState(() {
      isLoading = true;
    });
    String storedToken = await getTokenFromSharedPreferences();
    setState(() {
      token = storedToken;
    });
    // Call API data fetching after token is loaded
  }

 Future<void> sendData() async {
  var apiUrl = '$appApiUrl/send/message';
  final Map<String, String> headers = {
    'Authorization': 'Bearer $token',
  };

  final Map<String, dynamic> requestBody = {
    'phone': phone,
    'subject': subject,
    'message': message,
  };

  try {
    final response = await http.post(Uri.parse(apiUrl), headers: headers, body: requestBody);

    if (response.statusCode == 200) {
    
      showCustomErrorMessage(context,'Message sent we will get back to you in 24h'); // Show a success message
    } else if (response.statusCode == 400) {
      final validationErrors = json.decode(response.body);
      phoneError = validationErrors['validation_errors']['phone'][0];
      subjectError = validationErrors['validation_errors']['subject'][0];
      messageError = validationErrors['validation_errors']['message'][0];
      print(response.body);
    }
  } catch (e) {
        // showCustomErrorMessage(context,'Exception: $e');
        showCustomErrorMessage(context, 'Network error. check your internet connection');

  } finally {
    setState(() {
      isLoading = false; // Hide loading indicator
    });
  }
}





  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Write to Us'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
          onPressed: () {
            Navigator.pop(context); // Use pop to go back
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                 controller: _phoneController,
                onChanged: (value) {
                setState(() {
                phone = value; // Update the passwoord value variable with the current content
                phoneError = ''; // Clear the error message
                });
                },
                decoration: const InputDecoration(
                  labelText: 'Phone',
                  border: OutlineInputBorder(),
                ),
              ),
                Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        phoneError,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
               const SizedBox(height: 16.0),
              TextFormField(
                 controller: _subjectController,
                        onChanged: (value) {
                            setState(() {
                              subject = value; // Update the passwoord value variable with the current content
                              subjectError = ''; // Clear the error message
                            });
                        },
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  border: OutlineInputBorder(),
                ),
              ),
                Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        subjectError,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
              const SizedBox(height: 16.0),
              TextFormField(
                 controller: _messageController,
                        onChanged: (value) {
                            setState(() {
                              message = value; // Update the passwoord value variable with the current content
                              messageError = ''; // Clear the error message
                            });
                        },
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Message',
                  border: OutlineInputBorder(),
                ),
              ),
                Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        messageError,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
              const SizedBox(height: 16.0),
             
      
      
      
               MaterialButton(
                  minWidth: h * 0.9,
                  onPressed: () {
                    setState(() {
                      phone = _phoneController.text;
                      subject = _subjectController.text;
                      message = _messageController.text;
                    });
                    _loadToken();
                    sendData();
                  },
                  color: Colors.deepPurple,
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
      
                // const SizedBox(height: 16.0),
                // GestureDetector(
                //   onTap: () => _launchUrl(),
                //   child: const Row(
                //     children: [
                //       Icon(
                //         Icons.chat, // You can change this to the desired icon
                //         color: Colors.blue,
                //       ),
                //       SizedBox(width: 8.0), // Add some spacing between the icon and the text
                //       Text(
                //         'Click here to chat in WhatsApp',
                //         style: TextStyle(
                //           color: Colors.blue,
                //           decoration: TextDecoration.underline,
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
      
      
      
      
      
      
            ],
          ),
        ),
      ),
    );
  }
}
