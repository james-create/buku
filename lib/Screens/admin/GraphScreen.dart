import 'package:buku/Screens/utils/constarts.dart';
import 'package:buku/Screens/utils/custom_snacable.dart';
import 'package:buku/Screens/utils/token.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';

class GraphScreen extends StatefulWidget {
  const GraphScreen({super.key});

  @override
  _GraphScreenState createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  double userCount = 0; // User count obtained from the API
  double bookCount = 0; // Book count obtained from the API
  String apiUrl = "$appApiUrl/graph";
  bool isLoading = false;
  String token = '';

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
    fetchDataForGraph();
  }

  Future<void> fetchDataForGraph() async {
    setState(() {
      isLoading = true;
    });

    final headers = {
      'Authorization': 'Bearer $token', // Replace with your actual bearer token
    };
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final parsedData = json.decode(response.body);
      // Extract userCount and bookCount from the API response
      userCount = parsedData['userCount'].toDouble();
      bookCount = parsedData['bookCount'].toDouble();
    } else if (response.statusCode == 401) {
      ApiResponse.showSnackBar(context, 'Unauthorized: Token expired or missing.');
      // Handle unauthorized (token expired, missing token, etc.) here
    } else {
    ApiResponse.showSnackBar(context, 'API request error: ${response.statusCode}');
      // Handle other API request errors
    }
    setState(() {
      isLoading = false; // Set isLoading to false after data is loaded.
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  

        appBar: AppBar(title: const Text('Users & Books pie chart',style: TextStyle(color: Colors.white),),
     
        backgroundColor: Colors.deepPurple, // Set the background color to deep purple
    iconTheme: const IconThemeData(color: Colors.white), 
     ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator() // Display loading indicator while data is being fetched.
            : userCount > 0 && bookCount > 0
                ? Padding(
                  padding:const EdgeInsets.all(10),
                  child: Stack(
                      children: [
                        Container(
                          child: PieChart(
                            PieChartData(
                              sections: [
                                PieChartSectionData(
                                  title: 'Users : $userCount ',
                                  value: userCount,
                                  color: Colors.blue,
                                ),
                                PieChartSectionData(
                                  title: 'Books : $bookCount',
                                  value: bookCount,
                                  color: Colors.green,
                                ),
                              ],
                            ),
                          ),
                        ),
                 const Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.book_online,
                      size: 40, // You can adjust the size as needed
                      color: Colors.deepPurple,
                    ),
                    SizedBox(width: 10), // Add some spacing between the icon and text
                    Text(
                      'Learn star',
                      style: TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
              ),
              
                      ],
                    ),
                )
                : const Text('No data available'), // Display a message when there's no data.
      ),
    );
  }
}
