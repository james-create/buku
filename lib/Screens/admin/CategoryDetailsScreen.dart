import 'dart:convert';

import 'package:buku/Screens/admin/book_details.dart';
import 'package:buku/Screens/utils/constarts.dart';
import 'package:buku/Screens/utils/custom_snacable.dart';
import 'package:buku/Screens/utils/token.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CategoryDetailsScreen extends StatefulWidget {
  final int categoryId;

  

  const CategoryDetailsScreen({required this.categoryId, super.key});

  @override
  State<CategoryDetailsScreen> createState() => _CategoryDetailsScreenState();
}

class _CategoryDetailsScreenState extends State<CategoryDetailsScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool isLoading = false;
  String token = '';
  List<dynamic> responseItems = [];
  List<dynamic> filteredBooks = [];
  String category_name = '';
   String category_name_alone = '';
  

  
  

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
    String apiUrl = "$appApiUrl/books/category/${widget.categoryId}";
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
          category_name_alone=responseData['category_name'];
        });
      }
      else if(response.statusCode == 404)
      {
        final responseData = json.decode(response.body);
        setState(() {
           category_name_alone=responseData['category_name'];
        });
        ApiResponse.showSnackBar(context, 'No books found for the specified category');
      }
    } catch (e) {
       ApiResponse.showSnackBar(context, 'Network error. Check your internet connection');
      
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
     appBar: AppBar(title: Text('Category : $category_name_alone',style: const TextStyle(color: Colors.white),),
     
        backgroundColor: Colors.deepPurple, // Set the background color to deep purple
    iconTheme: const IconThemeData(color: Colors.white), 
     ),
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
           
                  if (filteredBooks.isEmpty)
                    SizedBox(
                      width: double.infinity, // Set the width to occupy the full width
                      child: Card(
                        color: Colors.purple[900],
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              const Icon(
                                Icons.bookmark_add_sharp,
                                size: 48,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "No book(s) was found for $category_name_alone. ",
                                style: const TextStyle(
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
