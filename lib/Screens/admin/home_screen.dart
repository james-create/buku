import 'package:buku/Screens/utils/custom_snacable.dart';
import 'package:flutter/material.dart';
import 'package:buku/Screens/admin/book_details.dart';
import 'package:buku/Screens/utils/constarts.dart';
import 'package:buku/Screens/utils/token.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool isLoading = false;
  String token = '';
  List<dynamic> responseItems = [];
  List<dynamic> filteredBooks = [];

  @override
  void initState() {
    super.initState();
    _loadToken();
    _searchController.addListener(_filterBooks);
  }

  Future<void> _loadToken() async {
    setState(() {
      isLoading = true;
    });
    String storedToken = await getTokenFromSharedPreferences();
    setState(() {
      token = storedToken;
    });
    fetchApiData();
  }

  Future<void> fetchApiData() async {
    String apiUrl = "$appApiUrl/books";
    final Map<String, String> headers = {
      'Authorization': 'Bearer $token',
    };
    try {
      final response = await http.get(Uri.parse(apiUrl), headers: headers);
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final books = responseData['book'];
        setState(() {
          responseItems = books;
          filteredBooks = books;
        });
      }
    } catch (e) {
       ApiResponse.showSnackBar(context, 'Network error. Check your internet connection.');
          // showCustomErrorMessage(context,'Network error. Check your internet connection');  
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

 void _filterBooks() {
  final query = _searchController.text.toLowerCase();
  setState(() {
    filteredBooks = responseItems.where((book) {
      final title = book['title'];
      final author = book['author'];
      final category = book['category_name'];
      
      if (title != null && title.toLowerCase().contains(query)) {
        return true;
      }
      if (author != null && author.toLowerCase().contains(query)) {
        return true;
      }
      if (category != null && category.toLowerCase().contains(query)) {
        return true;
      }
      
      return false;
    }).toList();
  });
}


  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    return Scaffold(
    
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        labelText: 'Search by title, author, category, ISBN, etc.',
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                          },
                        ),
                      ),
                    ),
                  ),
         Padding(
  padding: const EdgeInsets.all(5.0),
  child: Container(
    width: MediaQuery.of(context).size.width,
    height: MediaQuery.of(context).size.height * 0.07,
    decoration: const BoxDecoration(
      image: DecorationImage(
        image: AssetImage("images/books.jpg"),
        fit: BoxFit.cover,
      ),
    ),
  ),
),

                  const SizedBox(height: 2,),
                  if (filteredBooks.isEmpty)
                   Padding(
                    padding: const EdgeInsets.all(10),
              
                     child: Card(
                      color: Colors.purple[900],
                     elevation: 4, // Add some elevation to make it look like a card
                     shape: RoundedRectangleBorder(
                       borderRadius: BorderRadius.circular(10), // Customize the border radius
                     ),
                     child: const Padding(
                       padding: EdgeInsets.all(16.0),
                       child: Column(
                         mainAxisSize: MainAxisSize.min,
                         children: [
                           Icon(
                             Icons.bookmark_add_sharp, // You can replace this with any desired icon
                             size: 48, // Adjust the size of the icon
                             color: Colors.white, // Customize the icon color
                           ),
                           SizedBox(height: 10),
                           Text(
                             "No book(s) was found. Try a different search combination",
                             style: TextStyle(
                               color: Colors.white,
                               fontSize: 16,
                               fontWeight: FontWeight.bold,
                             ),
                             textAlign: TextAlign.center,
                           ),
                         ],
                       ),
                     ),
                   ),
                   )


                  else
                    GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 1.0,
                        mainAxisSpacing: 1.0,
                      ),
                      itemBuilder: (context, index) {
                        final item = filteredBooks[index];
                        String coverImageUrl =
                            '${fileAppApiUrl}cover_images/' + item['cover_image'];

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BookDetails(
                                  bookId: item['id'],
                                ),
                              ),
                            );
                          },
                          child: Card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Image.network(
                                  coverImageUrl,
                                  height: 130,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Text(
                                    '${item['title']} - ${item['category_name']}',
                                    style: const TextStyle(
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.purple,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(0.0),
                                  child: Align(
                                    alignment: Alignment.topRight,
                                    child: Align(
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        ' ${item['author']} :  ${item['date_written']} :  ${item['pages']} pages',
                                        style: const TextStyle(
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      itemCount: filteredBooks.length,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                    ),
                ],
              ),
            ),
    );
  }
}
