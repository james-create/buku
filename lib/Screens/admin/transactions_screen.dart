import 'dart:convert';
import 'package:buku/Screens/utils/constarts.dart';
import 'package:buku/Screens/utils/show_custom_error_message.dart';
import 'package:buku/Screens/utils/token.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class TransactionScreen extends StatefulWidget {
  const TransactionScreen({super.key});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  String token = '';
  bool isLoading = false;
  List<Map<String, dynamic>> transactions = [];

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
    String apiUrl = "$appApiUrl/transactions";
    final Map<String, String> headers = {
      'Authorization': 'Bearer $token',
    };
    try {
      final response = await http.get(Uri.parse(apiUrl), headers: headers);
      if (response.statusCode == 200) {
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
      appBar: AppBar(title: const Text('Mpesa payment history',style: TextStyle(color: Colors.white),),
     
        backgroundColor: Colors.deepPurple, // Set the background color to deep purple
    iconTheme: const IconThemeData(color: Colors.white), 
     ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : transactions.isEmpty
              ? const Center(child: Text('No transactions available'))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                    
                            const SizedBox(height: 10),
                            Text(
                              'Total Transactions: ${transactions.length}',
                              style: const TextStyle(),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Total Amount: KES ${calculateTotalAmount(transactions)}',
                       
                            ),
                          ],
                        ),
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('ID')),
                            DataColumn(label: Text('Phone')),
                            DataColumn(label: Text('Amount')),
                            DataColumn(label: Text('Code')),
                            DataColumn(label: Text('Date')),
                            // Add more DataColumn widgets for other fields
                          ],
                          rows: transactions
                              .map(
                                (transaction) => DataRow(
                                  cells: [
                                    DataCell(Text('${transaction['id']}')),
                                    DataCell(Text('${transaction['phonenumber']}')),
                                    DataCell(Text('KES ${transaction['amount']}')),
                                    DataCell(Text('${transaction['mpesa_receipt_number']}')),
                                    DataCell(Text('${transaction['transaction_date']}')),
                                    // Add more DataCell widgets for other fields
                                  ],
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }


  // Function to calculate the total amount
  double calculateTotalAmount(List<Map<String, dynamic>> transactions) {
    double totalAmount = 0;
    for (var transaction in transactions) {
      totalAmount += double.parse(transaction['amount'].toString());
    }
    return totalAmount;
  }
}

