import 'dart:convert';
import 'package:buku/Screens/admin/Mpesa.dart';
import 'package:buku/Screens/utils/constarts.dart';
import 'package:buku/Screens/utils/token.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PaymentScreen extends StatefulWidget {
  final int bookId;

  const PaymentScreen({super.key, required this.bookId});

  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String token = '';
  bool isLoading = true;
  Map<String, dynamic> responseData = {};

  String pdfFileUrl = '';
  String title = '';
  String coverImage = '';
  String description = '';
  String author = '';
  String pages = '';
  String createdAt = '';
  String category_name = '';
  String aob = '';
  int book_likes = 0;
  int cost = 0;

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    String storedToken = await getTokenFromSharedPreferences();
    setState(() {
      token = storedToken;
    });
    fetchApiData();
  }

  Future<void> fetchApiData() async {
         setState(() {
      isLoading = true;
    });
    var apiUrl = "$appApiUrl/book/${widget.bookId}";
    final Map<String, String> headers = {
      'Authorization': 'Bearer $token',
    };
    try {
      final response = await http.get(Uri.parse(apiUrl), headers: headers);
      if (response.statusCode == 200) {
        responseData = json.decode(response.body);
        setState(() {
          book_likes = int.parse(responseData['book']['book_likes']);
          pdfFileUrl = '${fileAppApiUrl}pdf_files/' + responseData['book']['pdf_file'];
          title = responseData['book']['title'];
          coverImage = '${fileAppApiUrl}cover_images/' + responseData['book']['cover_image'];
          description = responseData['book']['description'];
          author = responseData['book']['author'];
          pages = responseData['book']['pages'];
          createdAt = responseData['book']['created_at'];
          category_name = responseData['book']['category_name'];
          aob = responseData['book']['aob'];
          cost = int.parse(responseData['book']['cost']);
          isLoading = false; // Data has been loaded
        });
      } else if (response.statusCode == 400) {
        // Handle the 400 status code if needed
      }
    } catch (e) {
      // Handle network errors
       const SnackBar(
        content: Text('Network error: Unable to fetch data.'),
      );
    }finally
    {
      setState(() {
      isLoading = false;
    });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    
              appBar: AppBar(title: const Text('Select Payment Method  ',style: TextStyle(color: Colors.white),),
     
        backgroundColor: Colors.deepPurple, // Set the background color to deep purple
    iconTheme: const IconThemeData(color: Colors.white), 
     ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          child: Container(
            child: isLoading
              ? const CircularProgressIndicator()
              : Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Align content to the top
                children: [
                  Container(
                    child: Row(
                      children: [
                        Image.network(
                          coverImage,
                          width: 90,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Title: $title', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text('Author: $author'),
                              Text('Pages: $pages'),
                              Text('Created At: $createdAt'),
                              Text('Category: $category_name'),
                              Text('Likes: $book_likes'),
                              Text('Price: KES $cost', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16,color: Colors.orange)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
      
                  const SizedBox(height: 20),
                  const Center(child: Text('Select Payment Method below',style: TextStyle(color: Colors.deepPurple),)),
                    const SizedBox(height: 20),
      
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Mpesa(bookId: widget.bookId)),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                    child: Image.asset('images/mpesa.png', width: double.infinity, height: 100),
                  ),
      
                  const SizedBox(height: 20),
      
                  // ElevatedButton(
                  //   onPressed: () {
                     
                  //     ApiResponse.showSnackBar(context, 'Paypal option comming soon...');
                  //   },
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor: Colors.white,
                  //     foregroundColor: Colors.black,
                  //   ),
                  //   child: Image.asset('images/paypal.png', width:double.infinity, height: 100),
                  // ),
                ],
              ),
          ),
        ),
      ),
    );
  }
}