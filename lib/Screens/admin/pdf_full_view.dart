import 'dart:convert';
import 'package:buku/Screens/admin/root_screen.dart';
import 'package:buku/Screens/utils/constarts.dart';
import 'package:buku/Screens/utils/show_custom_error_message.dart';
import 'package:buku/Screens/utils/token.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfFullView extends StatefulWidget {
  final int bookId;
  const PdfFullView({required this.bookId, super.key});

  @override
  _PdfFullViewState createState() => _PdfFullViewState();
}

class _PdfFullViewState extends State<PdfFullView> {
  String token = '';
  Map<String, dynamic> responseData = {};
  bool isLoading = true;
  String pdfFileUrl = '';
  String title = '';
  String hasPaid = '';
  @override
  void initState() {
    super.initState();
    _loadToken();
  }
  Future<void> _loadToken() async {
    final storedToken = await getTokenFromSharedPreferences();
    if (mounted) {
      setState(() {
        token = storedToken;
      });
    }
    if (token.isNotEmpty) {
      await fetchApiData();
    }
  }

  Future<void> fetchApiData() async {
    final apiUrl = "$appApiUrl/book/${widget.bookId}";
    final headers = {
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.get(Uri.parse(apiUrl), headers: headers);

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        if (mounted) {
          setState(() {
            responseData = decodedResponse;
            pdfFileUrl = '${fileAppApiUrl}pdf_files/' + responseData['book']['pdf_file'];
            hasPaid = responseData['book']['paid'];
            title = responseData['book']['title'];
          });
        }
      } else if (response.statusCode == 400) {
        // Handle the case where the user does not have access to the PDF.
        // You can display an error message or navigate to another screen.
      }
    } catch (e) {
      // Handle network errors gracefully.
      if (mounted) {
        showCustomErrorMessage(
          context,
          'Network error. Check your internet connection',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  




  



  @override
  Widget build(BuildContext context) {
      final GlobalKey<SfPdfViewerState> pdfViewerKey = GlobalKey();
    return Scaffold(
           appBar: AppBar(title: Text(title,style: const TextStyle(color: Colors.white),),
     
        backgroundColor: Colors.deepPurple, // Set the background color to deep purple
    iconTheme: const IconThemeData(color: Colors.white), 
     ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Visibility(
              visible: hasPaid == 'Yes' && pdfFileUrl.isNotEmpty,
              replacement: Center(
        child: Column(
          children: [
            const Text(
              'PDF ONLY OPENS WHEN SUBSCRIPTION IS ACTIVE',
              style: TextStyle(color: Colors.red),
            ),

            const SizedBox(height: 10), // Add some spacing


            ElevatedButton(
              onPressed: () {
                // Add your logic for renewing the subscription here
                 Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RootScreen(),
                  ),
                );
              },


              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.deepPurple, // Set text color
              ),
              child: const Text('Back'),
            ),
          ],
        ),
      ),
              child: SfPdfViewer.network(
              pdfFileUrl,
              key: pdfViewerKey,
              canShowPaginationDialog: true,
              pageSpacing: 4,
              enableTextSelection: false, // Enable text selection
              canShowScrollHead: true,
              canShowScrollStatus: true,
              enableDoubleTapZooming: true
            )

            ),
    );
  }
}
