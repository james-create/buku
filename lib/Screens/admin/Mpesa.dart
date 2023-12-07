import 'dart:convert';

import 'package:buku/Screens/utils/constarts.dart';
import 'package:buku/Screens/utils/token.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart'; // Import this to use inputFormatters

class Mpesa extends StatefulWidget {
  final int bookId; // Change the data type to int

  const Mpesa({super.key, required this.bookId});

  @override
  State<Mpesa> createState() => _MpesaState();
}


class _MpesaState extends State<Mpesa> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String token = '';
  bool isLoading = false;
  String errorMessage = '';
  String customerMessage = '';
  Map<String, dynamic> responseData = {};



  String pdfFileUrl = ''; // Declare the pdf_file URL
  String title = '';
  String coverImage = '';
  String description = '';
  String author = '';
  String pages = '';
  String createdAt = '';
  String category_name = '';
  String aob = '';
  int book_likes = 0; 
  int cost=0;
  




  Future<void> _makePayment() async {
  setState(() {
    isLoading = true;
  });
  try {
    final Map<String, dynamic> paymentData = {
      'phone': _phoneController.text,
      'amount': cost,
      'des': title,
      'email': _emailController.text,
      'book_id': widget.bookId, // Use widget.bookId without the dollar sign
    };
    print(paymentData);
    final response = await http.post(
      Uri.parse('$appApiUrl/stk'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(paymentData),
    );

   if (response.statusCode == 200) {
    responseData = json.decode(response.body);
    final errorMessage = responseData['errorMessage'];
    final customerMessage = responseData['CustomerMessage'];
    _phoneController.clear();
    _emailController.clear();

  setState(() {
    // Check if errorMessage is not null
    this.errorMessage = errorMessage ?? '';
    // Check if customerMessage is not null
    this.customerMessage = customerMessage ?? '';
  });
    }
  } catch (e) {
    // Show an error message to the user.
    setState(() {
      errorMessage = 'An error occurred. Please try again.';
    });
    const SnackBar(
        content: Text('Network error: Unable to fetch data.'),
      );
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}





  Future<void> _loadToken() async {
    // setState(() {
    //   isLoading = true;
    // });
    String storedToken = await getTokenFromSharedPreferences();
    setState(() {
      token = storedToken;
    });
    fetchApiData();
    // Call API data fetching after token is loaded
  }

  @override
  void initState() {
    super.initState();
    _loadToken();
  }





  Future<void> fetchApiData() async {
    var apiUrl = "$appApiUrl/book/${widget.bookId}"; // Use widget.bookId
    final Map<String, String> headers = {
      'Authorization': 'Bearer $token',
    };
    try {
      final response = await http.get(Uri.parse(apiUrl), headers: headers);
      if (response.statusCode == 200) {
        responseData = json.decode(response.body); // Parse and set response data
      
        
        // print(int.parse(responseData['book']['book_likes']));
        // print("Parsed book_likes: $book_likes");
        setState(() {
          book_likes = int.parse(responseData['book']['book_likes']);
          pdfFileUrl = '${fileAppApiUrl}pdf_files/' + responseData['book']['pdf_file'];
          title = responseData['book']['title'];
          coverImage =  '${fileAppApiUrl}cover_images/' + responseData['book']['cover_image'];
          description = responseData['book']['description'];
          author = responseData['book']['author'];
          pages = responseData['book']['pages'];
          createdAt = responseData['book']['created_at'];
          category_name = responseData['book']['category_name'];
          aob = responseData['book']['aob'];
          cost = int.parse(responseData['book']['cost']);          
        }); 

      } else if(response.statusCode==400) {
    
      }
   
    } catch (e) {
      // showCustomErrorMessage(context, 'Network error. check your internet connection');


    } finally {
      setState(() {
        isLoading = false; // Hide loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
              appBar: AppBar(title: const Text('Mpesa Option  ',style: TextStyle(color: Colors.white),),
     
        backgroundColor: Colors.deepPurple, // Set the background color to deep purple
    iconTheme: const IconThemeData(color: Colors.white), 
     ),
      body: SingleChildScrollView(
        child: Padding(
          
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[

               Column(
  children: [
    Row(
      children: [
        // Image on the left
        coverImage.isEmpty
  ? Container(child: const Text('Loading...'),) // Display an empty container if coverImage is empty
  : Image.network(
      coverImage,
      width: 90,
      height: 100,
      fit: BoxFit.cover,
    ),

        const SizedBox(width: 16), // Add some spacing between the image and text
        // Description on the right
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text('Title: $title'),

              // Author
              Text('Author: $author'),

              // Pages
              Text('Pages: $pages'),

              // Created At
              Text('Created At: $createdAt'),

              // Category Name
              Text('Category: $category_name'),

            

              // Book Likes
              Text('Likes: $book_likes'),

              // Cost
              Text('Cost: KES $cost'),
            ],
          ),
        ),
      ],
    ),
  ],
),

                
               Image.asset('images/mpesa.png', width: 100, height: 100),
                  Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white, // Background color of the container
                          borderRadius: BorderRadius.circular(2), // Optional: Round the corners of the container
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5), // Shadow color
                              spreadRadius: 2, // Spread radius
                              blurRadius: 5, // Blur radius
                              offset: const Offset(0, 3), // Shadow position
                            ),
                          ],
                        ),
                        margin: const EdgeInsets.all(2), // Optional: Adjust margin for better spacing
                        padding: const EdgeInsets.all(8), // Optional: Adjust padding for text inside the container
                        child: const Text('1. Please enter your Safaricom phone number in the format 254XXXXXXXXX, then click "Make Payment".'),
                      ),
     Container(
                        decoration: BoxDecoration(
                          color: Colors.white, // Background color of the container
                          borderRadius: BorderRadius.circular(2), // Optional: Round the corners of the container
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5), // Shadow color
                              spreadRadius: 2, // Spread radius
                              blurRadius: 5, // Blur radius
                              offset: const Offset(0, 3), // Shadow position
                            ),
                          ],
                        ),
                        margin: const EdgeInsets.all(2), // Optional: Adjust margin for better spacing
                        padding: const EdgeInsets.all(8), // Optional: Adjust padding for text inside the container
                        child: Text('2. You will receive a prompt on your phone to confirm payment of KES $cost.  enter your PIN to confirm.'),
                      ),

     Container(
                        decoration: BoxDecoration(
                          color: Colors.white, // Background color of the container
                          borderRadius: BorderRadius.circular(2), // Optional: Round the corners of the container
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5), // Shadow color
                              spreadRadius: 2, // Spread radius
                              blurRadius: 5, // Blur radius
                              offset: const Offset(0, 3), // Shadow position
                            ),
                          ],
                        ),
                        margin: const EdgeInsets.all(2), // Optional: Adjust margin for better spacing
                        padding: const EdgeInsets.all(8), // Optional: Adjust padding for text inside the container
                        child: const Text('3. Once confirmed, the E-book will be sent to the provided email address as well as the registered one.'),
                      ),




                  
                    ],
                  ),

                const SizedBox(width: 40),
                const SizedBox(height: 20,),

   
          Visibility(
  visible: customerMessage.isNotEmpty || errorMessage.isNotEmpty,
  child: Container(
    width: double.infinity,
    color: Colors.white70,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (customerMessage.isNotEmpty)
          Container(
            color: Colors.green,
            padding: const EdgeInsets.all(8),
            width: double.infinity,
            child: Text(
              '$customerMessage check your phone to confirm payment and then check the email provided for the PDF file',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        if (errorMessage.isNotEmpty)
          Container(
            color: Colors.red,
            padding: const EdgeInsets.all(8),
            width: double.infinity,
            child: Text(
              errorMessage,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
      ],
    ),
  ),
),

                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone Number(e.g 254xxxxxxxxx)'),
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Please enter a valid phone number';
                    }
                         errorMessage='';
                    return null;
                  },
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                  ],
                ),
               TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email to receive the PDF'),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return 'Please enter an email address';
                  }

                  // Use a regular expression to validate the email format
                  if (!RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$').hasMatch(value!)) {
                    return 'Please enter a valid email address';
                  }

                  errorMessage = '';
                  return null;
                },
              ),

      
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      _makePayment();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20), // Adjust the horizontal padding as needed
                    minimumSize: const Size(double.infinity, 50), // Set the desired height
                  ),
                  child: isLoading
                      ? const Column(
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                            Text('Sending STK', style: TextStyle(color: Colors.white)),
                          ],
                        )
                      : const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text('Make Payment ')),
                )
      
      
              ],
            ),
           
          ),
        ),
      ),
       
    );
  }
}
