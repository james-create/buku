import 'dart:convert';
import 'package:buku/Screens/admin/paymentScreen.dart';
import 'package:buku/Screens/admin/pdf_full_view.dart';
import 'package:buku/Screens/admin/subscription_screen.dart';
import 'package:buku/Screens/utils/constarts.dart';
import 'package:buku/Screens/utils/custom_snacable.dart';
import 'package:buku/Screens/utils/show_custom_error_message.dart';
import 'package:buku/Screens/utils/token.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BookDetails extends StatefulWidget {
  final int bookId; // Define the bookId parameter
  const BookDetails({required this.bookId, super.key});
  @override
  _BookDetailsState createState() => _BookDetailsState();
}

class _BookDetailsState extends State<BookDetails> {
  String token = '';
  Map<String, dynamic> responseData = {}; // Store response data as a Map
  bool isLoading = false;
  bool isLikeLoading = false;
  bool isCommentLoading = false;
 bool isAddToWishListLoading = false;


  
  String pdfFileUrl = ''; // Declare the pdf_file URL
  String title = '';
  String coverImage = '';
  String description = '';
  String author = '';
  String pages = '';
  String createdAt = '';
  String category_name = '';
  String aob = '';
  String hasPaid='';
  int bookId=0;
  int book_likes = 0; 
  int cost=0;

  // get what the user typed
  final _commentController=TextEditingController();
  // stores what the user typed
  String comment='';
  // errors
  String commentError = '';

  List<dynamic> commentsList = []; // Change to a List
   

  Future<void> _loadToken() async {
    setState(() {
      isLoading = true;
    });
    String storedToken = await getTokenFromSharedPreferences();
    setState(() {
      token = storedToken;
    });
    // Call API data fetching after token is loaded
    fetchApiData();
  }



  Future<void> fetchApiData() async {
    var apiUrl = "$appApiUrl/book/${widget.bookId}"; // Use widget.bookId
    final Map<String, String> headers = {
      'Authorization': 'Bearer $token',
    };
    try {
      final response = await http.get(Uri.parse(apiUrl), headers: headers);
      if (response.statusCode == 200) {
        responseData = json.decode(response.body); // Parse and set response data
        
        // print(int.parse(responseData['book']['book_likes']));
        // print("Parsed book_likes: $book_likes");
        setState(() {
          book_likes = int.parse(responseData['book']['book_likes']);
          pdfFileUrl = '${fileAppApiUrl}pdf_files/' + responseData['book']['pdf_file'];
          title = responseData['book']['title'];
          coverImage =  '${fileAppApiUrl}cover_images/' + responseData['book']['cover_image'];
          description = responseData['book']['description'];
          author = responseData['book']['author'];
          pages = responseData['book']['pages'];
          createdAt = responseData['book']['created_at'];
          category_name = responseData['book']['category_name'];
          aob = responseData['book']['aob'];
          hasPaid = responseData['book']['paid'];
          bookId = responseData['book']['id'];
          cost = int.parse(responseData['book']['cost']);
          commentsList = responseData['comments'] as List<dynamic>; // Store comments as a List
              
        }); 

      } else if(response.statusCode==400) {
         // ignore: use_build_context_synchronously
         Navigator.push(
         context,
         MaterialPageRoute(builder: (context) => const SubscriptionScreen()),
                          );
      }
   
    } catch (e) {
      // showCustomErrorMessage(context, 'Network error. check your internet connection');


    } finally {
      setState(() {
        isLoading = false; // Hide loading indicator
      });
    }
  }



 Future<void> likeBook() async {
     setState(() {
      isLikeLoading = true;
    });
    var apiUrl = "$appApiUrl/like/${widget.bookId}"; // Use widget.bookId
    final Map<String, String> headers = {
      'Authorization': 'Bearer $token',
    };
    try {
      final response = await http.post(Uri.parse(apiUrl), headers: headers);
      if (response.statusCode == 200) {
        fetchApiData();
      } 
    } catch (e) {
             print(e);
      // showCustomErrorMessage(context, 'Network error. check your internet connection');
     
    } finally {
      setState(() {
        isLikeLoading = false; // Hide loading indicator
      });
    }
  }





 Future<void> addBookToWishList() async {
     setState(() {
      isAddToWishListLoading = true;
    });
    var apiUrl = "$appApiUrl/wish/list/${widget.bookId}"; // Use widget.bookId
    final Map<String, String> headers = {
      'Authorization': 'Bearer $token',
    };
    try {
      final response = await http.post(Uri.parse(apiUrl), headers: headers);
      if (response.statusCode == 200) {
      ApiResponse.showSnackBar(context, 'Added to favorites.');
      } 
    } catch (e) {
             print(e);
      // showCustomErrorMessage(context, 'Network error. check your internet connection');
     
    } finally {
      setState(() {
        isAddToWishListLoading = false; // Hide loading indicator
      });
    }
  }




  Future<void> _comment() async {
    setState(() {
      isCommentLoading = true;
    });
  var apiUrl = '$appApiUrl/comment/$bookId';
  final Map<String, String> headers = {
    'Authorization': 'Bearer $token',
  };
  final Map<String, dynamic> requestBody = {
    'comment': comment,
  };
  try {
    final response = await http.post(Uri.parse(apiUrl), headers: headers, body: requestBody);
    if (response.statusCode == 200) {
       comment="";
       fetchApiData();
       ApiResponse.showSnackBar(context, 'Your comment was submitted');
       _commentController.clear();
    } else if (response.statusCode == 400) {
      final validationErrors = json.decode(response.body);
      commentError = validationErrors['validation_errors']['comment'][0];
    }
   
  } catch (e) {
    // Handle the exception
       showCustomErrorMessage(context,'Exception: $e');
  } finally {
    setState(() {
      isCommentLoading = false; // Hide loading indicator
    });
  }
}



// token run fiirst then comment
@override
void initState() {
  super.initState();
  _loadToken();
}




@override
Widget build(BuildContext context) {
     double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
  return Scaffold(
      appBar: AppBar(title: Text(title,style: const TextStyle(color: Colors.white),),
        backgroundColor: Colors.deepPurple, // Set the background color to deep purple
    iconTheme: const IconThemeData(color: Colors.white), 
     ),
    body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // PDF Viewer
               if (hasPaid == 'Yes' && pdfFileUrl.isNotEmpty)
                const Text('')
                else
                const Center(child: Text('PDF ONLY OPEN WHEN SUBSCRIPTION IS ACTIVE',style: TextStyle(color: Colors.red),)
                ),
                
                // Left column with cover image and book information
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10.0),
                      child: Image.network(
                        coverImage,
                        width: 90,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                   
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Text('Category: $category_name',
                              style: const TextStyle(
                                fontSize: 12,
                              ),
                            ),
                             Text('Author: $author',
                              style: const TextStyle(
                                fontSize: 12,
                              ),
                            ),
                            Text('Pages: $pages',
                            style: const TextStyle(
                                fontSize: 12,
                              ),
                              ),
                            Text('Posted: $createdAt',
                            style: const TextStyle(
                                fontSize: 12,
                              ),
                            ),
                              Text('Active subscription: $hasPaid',
                            style: const TextStyle(
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 10),
                                     Text(' KES $cost',
                            style: const TextStyle(
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 10),
                         
                        
                         Row(
                          children: [
                            Container(
                              child: GestureDetector(
                                onTap: () {
                                 likeBook();
                                },
                                child: const Icon(
                                  Icons.thumb_up,
                                  color: Colors.blue, // Set the color to blue
                                ),
                              ),
                            ),
                            const SizedBox(width: 5), // Add spacing between the icon and text
                            isLikeLoading?const Text('Loading..') : GestureDetector(
                              onTap: () {
                                 likeBook();
                                },
                              child: Text('$book_likes Likes')),

                              const SizedBox(width: 10),
                              Container(
                              child: GestureDetector(
                                onTap: () {
                                 addBookToWishList();
                              
                                },
                                child: const Icon(
                                  Icons.favorite,
                                  color: Colors.deepPurple, // Set the color to blue
                                ),
                              ),
                            ),
                            const SizedBox(width: 0), // Add spacing between the icon and text
                            GestureDetector(
                                onTap: () {
                                 addBookToWishList();
                                },
                              child: isAddToWishListLoading?const Text('Loading...') : const Text('Add to Favorite')),

                
                          ],
                        ),


                            


                        const SizedBox(height: 20),

                     Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Adjust this based on your layout preferences
  children: [
    GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PdfFullView(bookId: bookId),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(0),
          boxShadow: [
            BoxShadow(
              color: Colors.indigo.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 2,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min, // Adjust this to your preferences
          children: [
            Icon(
              Icons.library_books,
              color: Colors.black,
              size: 28,
            ),
            SizedBox(width: 10),
            Text(
              'Read',
              style: TextStyle(
                color: Colors.deepPurple,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    ),

    

    GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentScreen(bookId: bookId),
          ),
        );
      },
      child: Container(
        
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(0),
          boxShadow: [
            BoxShadow(
              color: Colors.indigo.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 2,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min, // Adjust this to your preferences
          children: [
            Icon(
              Icons.money,
              color: Colors.black,
              size: 28,
            ),
            SizedBox(width: 10),
            Text(
              'Buy',
              style: TextStyle(
                color: Colors.deepPurple,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                
              ),
            ),
          ],
        ),
      ),
    ),
  ],
),


                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                // Description
                Padding(
                  padding: const EdgeInsets.all(7.0),
                  child: Text(
                    description,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                 // Description
                Padding(
                  padding: const EdgeInsets.all(7.0),
                  child: Text(
                    aob,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
             
             

 









Column(
  children: [
    Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(1.0),
          color: Colors.grey[200],
        ),
        child: Row(
          children: [
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 0.0),
                child: TextFormField(
                  controller: _commentController,
                  onChanged: (value) {
                    setState(() {
                      comment = value;
                      commentError = '';
                    });
                  },
                  maxLines: 6,
                  decoration: const InputDecoration(
                    hintText: 'Write your comment here',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(8.0),
                  ),
                  style: const TextStyle(fontSize: 16.0),
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                _comment();
                fetchApiData();
              },
              icon: const Icon(
                Icons.send,
                color: Colors.deepPurple,
              ),
            ),
          ],
        ),
      ),
    ),
    Padding(
      padding: const EdgeInsets.all(7),
      child: Align(
          alignment: Alignment.topLeft,
          child: Text(commentError, style: const TextStyle(color: Colors.red)),
        ),
    ),
    
  ],
),

const SizedBox(height: 1,),


Padding(
  padding: const EdgeInsets.all(2),
  child: Container(
    width: double.infinity,
    height: 23, // Increased height by 2 pixels
    color: Colors.deepPurple,
    child: Center(
      child: Column(
        children: [
          Text(
            'Total Comments: ${commentsList.length}',
            style: const TextStyle(
              fontSize: 16.0,
              color: Colors.white,
            ),
          ),
        ],
      ),
    ),
  ),
),


  // ListView.builder to display comments
Padding(
  padding: const EdgeInsets.all(10),
  child:   SingleChildScrollView(
    child: ListView.builder(
      shrinkWrap: true,
      itemCount: commentsList.length,
      itemBuilder: (BuildContext context, int index) {
        final commentData = commentsList[index];
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4.0), // Adjust the margin as needed
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5), // Shadow color
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2), // Shadow position (horizontal, vertical)
              ),
            ],
          ),
          child: ListTile(
            title: Text(
              commentData['user_name'], // Username on the first line
              style: const TextStyle(fontSize: 12,color:Colors.deepPurple), // Customize username style
            ),
           subtitle: Row(
              children: [
                const Icon(
                  Icons.message, // You can replace this with your desired message icon
                  size: 16.0, // Adjust the size as needed
                  color: Colors.blue, // Change the color to match your design
                ),
                const SizedBox(width: 4.0), // Add some spacing between the icon and text
                Text(
                  commentData['comment'], // Comment on the second line
                  style: const TextStyle(fontSize: 12.0, color: Colors.black),
                ),
              ],
            ),

            // You can customize the appearance of the created_at text here
            trailing: Text(
              commentData['created_at'],
              style: const TextStyle(fontSize: 12.0, color: Colors.grey),
            ),
          ),
        );
      },
    ),
  ),
),






              ],
            ),
          ),
  );
}
}