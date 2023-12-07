import 'dart:convert';
import 'package:buku/Screens/utils/constarts.dart';
import 'package:buku/Screens/utils/token.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  bool isUserLoading = false;
  bool isChangeStetLoading = false;
  String token = '';
  List<dynamic> usersList = [];
  int userId=0;

  Future<void> _loadToken() async {
    setState(() {
      isUserLoading = true;
    });
    String storedToken = await getTokenFromSharedPreferences();
    setState(() {
      token = storedToken;
    });
    users();
  }

  // get all users
  Future<void> users() async {
    setState(() {
      isUserLoading = true;
    });
    var apiUrl = '$appApiUrl/users';
    final Map<String, String> headers = {
      'Authorization': 'Bearer $token',
    };
    try {
      final response = await http.get(Uri.parse(apiUrl), headers: headers);
      // print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        // print(responseData);

        setState(() {
          usersList = responseData['users'] as List<dynamic>;
        });
      }
    } catch (e) {
      print(e);
      // showCustomErrorMessage(context, 'Network error. check your internet connection');
    } finally {
      setState(() {
        isUserLoading = false; // Hide loading indicator
      });
    }
  }


  // get all users
  Future<void> changeState(userId) async {
    setState(() {
      isUserLoading = true;
    });
    var apiUrl = '$appApiUrl/user/state/$userId';
    final Map<String, String> headers = {
      'Authorization': 'Bearer $token',
    };
    try {
      final response = await http.post(Uri.parse(apiUrl), headers: headers);
      // print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        users();
      }
    } catch (e) {
      print(e);
      // showCustomErrorMessage(context, 'Network error. check your internet connection');
    } finally {
      setState(() {
        isUserLoading = false; // Hide loading indicator
      });
    }
  }

  

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
   appBar: AppBar(title: const Text('Users',style: TextStyle(color: Colors.white),),
     
        backgroundColor: Colors.deepPurple, // Set the background color to deep purple
    iconTheme: const IconThemeData(color: Colors.white), 
     ),
      body: isUserLoading
          ? const Center(child: CircularProgressIndicator()) // Display a loading indicator while fetching data
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 20.0, // Adjust the spacing between columns
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black), // Add border to the table
                ),
                columns: const [
                  DataColumn(
                    label: Text(
                      'Paid',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'ID',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Name',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Email',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Username',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  
                  DataColumn(
                    label: Text(
                      'Role ID',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Activated On',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Deactivated On',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
          
                  DataColumn(
                    label: Text(
                      'School',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Joined',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Updated At',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                rows: usersList
                    .map(
                      (user) => DataRow(
                        cells: [
                          
                          DataCell(
                          TextButton(
                            onPressed: () {
                             changeState(user['id']);
                            },
                            child: user['paid'] == 0
                                ? const Icon(Icons.close, color: Colors.red) 
                                : const Icon(Icons.check, color: Colors.green), // Check icon for paid=1
                          ),
                        ),

                          DataCell(
                            Text(user['id'].toString()),
                            // Add border to individual cells
                            onTap: () {}, // You can add onTap for each cell
                          ),
                          DataCell(
                            Text(user['name'] ?? ''),
                          ),
                          DataCell(
                            Text(user['email'] ?? ''),
                          ),
                          DataCell(
                            Text(user['username'] ?? ''),
                          ),
                          DataCell(
                            Text(
                              user['role_id'] == 1
                                  ? 'Admin'
                                  : user['role_id'] == 2
                                      ? 'Member'
                                      : 'Subscriber',
                            ),
                          ),

                          DataCell(
                            Text(user['activated_on'] ?? ''),
                          ),
                          DataCell(
                            Text(user['deactivated_on'] ?? ''),
                          ),
              
                          DataCell(
                            Text(user['school'] ?? ''),
                          ),
                          DataCell(
                            Text(user['created_at'] ?? ''),
                          ),
                          DataCell(
                            Text(user['updated_at'] ?? ''),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
    );
  }
}
