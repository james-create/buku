import 'package:buku/Screens/admin/pdf_full_view.dart';
import 'package:buku/Screens/admin/root_screen.dart';
import 'package:buku/Screens/utils/custom_snacable.dart';
import 'package:flutter/material.dart';

import 'dart:convert';
import 'package:buku/Screens/utils/constarts.dart';
import 'package:buku/Screens/utils/token.dart';
import 'package:http/http.dart' as http;



class WishListScreen extends StatefulWidget {
  const WishListScreen({super.key});

  @override
  State<WishListScreen> createState() => _WishListScreenState();
}

class _WishListScreenState extends State<WishListScreen> {
  String token = '';
  bool isLoading = false;  
  Map<String, dynamic> responseData = {}; // Store response data as a Map
  List<dynamic> data = []; // Change to a List
 bool isRemoveToWishListLoading = false;  
  



@override
void initState() {
  super.initState();
  _loadToken();
}


Future<void> _loadToken() async {
  setState(() {
    isLoading = true;
  });
  String storedToken = await getTokenFromSharedPreferences();
  setState(() {
    token = storedToken;
  });
  // Call API data fetching after token is loaded
  fetchApiData(); // Call fetchApiData here
}


Future<void> fetchApiData() async {
  print('called');
  var apiUrl = "$appApiUrl/get/wish/list/"; 
  final Map<String, String> headers = {
    'Authorization': 'Bearer $token',
  };
  try {
    final response = await http.get(Uri.parse(apiUrl), headers: headers);
    if (response.statusCode == 200) {
      responseData = json.decode(response.body); // Parse and set response data
      if (responseData['data'] != null && responseData['data'] is List<dynamic>) {
        setState(() {
          data = responseData['data'] as List<dynamic>; // Store data as a List
        });
      } else {
          }
    } else if (response.statusCode == 400) {

    }
  } catch (e) {
    // Handle the network error case
    ApiResponse.showSnackBar(context, 'Network error. check your internet connection.');
  } finally {
    setState(() {
      isLoading = false; // Hide loading indicator
    });
  }
}





 Future<void> removeBookToWishList(id) async {
     setState(() {
      isRemoveToWishListLoading = true;
    });
    var apiUrl = "$appApiUrl/remove/wish/list/$id"; 
    final Map<String, String> headers = {
      'Authorization': 'Bearer $token',
    };
    try {
      final response = await http.post(Uri.parse(apiUrl), headers: headers);
      if (response.statusCode == 200) {
      ApiResponse.showSnackBar(context, 'Removed from favorites.');
      fetchApiData();
      } 
    } catch (e) {
    print(e);
    // showCustomErrorMessage(context, 'Network error. check your internet connection');
     
    } finally {
      setState(() {
        isRemoveToWishListLoading = false; // Hide loading indicator
      });
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: isLoading
        ? const Center(child: CircularProgressIndicator()) // Display a loading indicator while data is being fetched.
        : data.isEmpty
            ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('No books in the Favorite list.'),
                const SizedBox(height: 16), // Add some spacing
                ElevatedButton(
                  onPressed: () {
                   Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RootScreen()),
                  );
                  },
                  child: const Text('Add a Book'),
                ),
              ],
            ),
          )

            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child:isRemoveToWishListLoading? const Text('Loading...') : Text(
                      'My favorite books : ${data.length}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final book = data[index]['book'];
                        final category = book['category']; // Category information
                        String coverImageUrl = '${fileAppApiUrl}cover_images/' + book['cover_image'];
                        return Card(
                          elevation: 6, // Add shadow to the card
                          margin: const EdgeInsets.all(5), // Add some margin around the card
                          child: ListTile(
                            leading: Image.network(coverImageUrl, height: 100, width: 100), // Display the cover image
                            title: Text(
                              book['title'],
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Author: ${book['author']}'),
                                Text('Category: ${book['category']['name']}'), // Display the category name
                                Text('Date written: ${book['date_written']}'),
                                Text('Pages: ${book['pages']}'),
                                // Add other details here
                                TextButton(
                                  onPressed: () {
                                    removeBookToWishList(book['id']);
                                  },
                                  child: const Row(
                                    children: [
                                      Icon(Icons.cancel),
                                      Text('Remove'),
                                       // You can change the icon to the appropriate one
                                    ],
                                  ),
                                )
                              ],
                            ),
                            onTap: () {
                              print(book['id']);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PdfFullView(bookId: book['id']),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
  );
}



}