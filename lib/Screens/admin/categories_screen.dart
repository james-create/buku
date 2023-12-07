import 'dart:convert';
import 'package:buku/Screens/admin/CategoryDetailsScreen.dart';
import 'package:buku/Screens/utils/constarts.dart';
import 'package:buku/Screens/utils/custom_snacable.dart';
import 'package:buku/Screens/utils/token.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  String token = '';
  bool isLoading = false;
  Map<String, dynamic> responseData = {};
  List<dynamic> data = [];

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
    fetchApiData();
  }

  Future<void> fetchApiData() async {
    var apiUrl = "$appApiUrl/categories/";
    final Map<String, String> headers = {
      'Authorization': 'Bearer $token',
    };
    try {
      final response = await http.get(Uri.parse(apiUrl), headers: headers);
      if (response.statusCode == 200) {
        responseData = json.decode(response.body);
       if (responseData['categories'] != null && responseData['categories'] is List<dynamic>) {
        setState(() {
          data = responseData['categories'] as List<dynamic>; // Store data as a List
        });
      } else {
        // Handle the case when 'categories' is null or not a List<dynamic>
        print('Invalid data format for "categories"');
      }

      } else if (response.statusCode == 400) {
        // Handle the case when the response status code is 400
      }
    } catch (e) {
        ApiResponse.showSnackBar(context, '$e');
    } 
    
    finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categories',style: TextStyle(color: Colors.white),),
            backgroundColor: Colors.deepPurple, // Set the background color to deep purple
    iconTheme: const IconThemeData(color: Colors.white), // Set icon color to white
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final category = data[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text(
                      category['name'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CategoryDetailsScreen(categoryId: category['id']),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
