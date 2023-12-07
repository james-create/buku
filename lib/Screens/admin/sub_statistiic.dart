import 'dart:convert';

import 'package:buku/Screens/utils/constarts.dart';
import 'package:buku/Screens/utils/show_custom_error_message.dart';
import 'package:buku/Screens/utils/token.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SubStatistics extends StatefulWidget {
  const SubStatistics({super.key});

  @override
  State<SubStatistics> createState() => _SubStatisticsState();
}

class _SubStatisticsState extends State<SubStatistics> {
  

  String token = '';
  bool isLoading = false;
  List<Map<String, dynamic>> transactions = [];

    Color getCellColor(String dueDate) {
    DateTime due = DateTime.parse(dueDate);
    DateTime today = DateTime.now();

    if (due.isBefore(today)) {
      return Colors.red;
    } else {
      return Colors.green;
    }
  }

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
    await fetchApiData();
  }

  Future<void> fetchApiData() async {
    String apiUrl = "$appApiUrl/subscription";
    final Map<String, String> headers = {
      'Authorization': 'Bearer $token',
    };
    try {
      final response = await http.get(Uri.parse(apiUrl), headers: headers);
      if (response.statusCode == 200) {
        print(response.body);
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData.containsKey('data')) {
          setState(() {
            transactions = List<Map<String, dynamic>>.from(responseData['data']);
          });
        }
      }
    } catch (e) {
      print(e);
      showCustomErrorMessage(context, 'Network error. Check your internet connection $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }



@override
Widget build(BuildContext context) {
  return Scaffold(
 

      appBar: AppBar(title: const Text('Subscribed Statistics  ',style: TextStyle(color: Colors.white),),
     
        backgroundColor: Colors.deepPurple, // Set the background color to deep purple
    iconTheme: const IconThemeData(color: Colors.white), 
     ),
    body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : transactions.isEmpty
            ? const Center(child: Text('No data available'))
            : SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('ID')),
                      DataColumn(label: Text('User ID')),
                      DataColumn(label: Text('Due Date')),
                      DataColumn(label: Text('Days')),
                      DataColumn(label: Text('Created ')),
                      DataColumn(label: Text('Updated ')),
                    ],
                    rows: transactions
                        .map(
                          (data) => DataRow(
                            cells: [
                              DataCell(Text(data['id'].toString())),
                              DataCell(Text(data['user_id'].toString())),
                            DataCell(
                            Text(
                              data['due_date'],
                              style: TextStyle(
                                color: getCellColor(data['due_date']),
                              ),
                            ),
                          ),

                              DataCell(Text(data['days'].toString())),
                              DataCell(Text(data['created_at'])),
                              DataCell(Text(data['updated_at'])),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
  );
}
}