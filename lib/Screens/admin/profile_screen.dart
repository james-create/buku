import 'package:buku/Screens/admin/edit_profile_screen.dart';
 // Fix the import statement
import 'package:buku/Screens/utils/constarts.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:buku/Screens/utils/token.dart'; // Import your token function

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key}); // Correct the key parameter syntax

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? profileData;
  String token = '';
  bool isLoading = true; // Initialize loading state as true
  String image_url = '';
  String coverImageUrl = ''; // Initialize coverImageUrl as an empty string

  @override
  void initState() {
    super.initState();
    _loadToken();
  }

  Future<void> _loadToken() async {
    String storedToken = await getTokenFromSharedPreferences();
    setState(() {
      token = storedToken;
    });
    // After loading the token, fetch the profile data
    fetchProfileData(token);
  }

  Future<void> fetchProfileData(String token) async {
    final url = Uri.parse('$appApiUrl/profile');
    final headers = {
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          profileData = jsonResponse['data'];
          image_url = jsonResponse['data']['image'];
          coverImageUrl = '${fileAppApiUrl}images/$image_url'; // Construct coverImageUrl here
        });
      } else {
        throw Exception('Failed to load profile data');
      }
    } catch (e) {
      print('Error fetching profile data: $e');
      // Handle errors here (e.g., show an error message)
      setState(() {
        profileData = null;
      });
    } finally {
      setState(() {
        isLoading = false; // Set loading state to false regardless of success or failure
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : profileData != null
              ? buildProfileView()
              : GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfileScreen(),
                      ),
                    );
                  },
                  child: Padding(
                padding: const EdgeInsets.all(10),
                child: Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    width: double.infinity,
                    child: const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(Icons.add, color: Colors.deepPurple),
                          SizedBox(width: 8.0),
                          Text(
                            'Add profile',
                            style: TextStyle(color: Colors.deepPurple),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )

                ),
    );
  }

  Widget buildProfileView() {
    return SingleChildScrollView(
      
      
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            // Display the image using coverImageUrl
            GestureDetector(
                 onTap: (){
                 Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditProfileScreen(),
                            ),
                          );
                        
              },
              child: SizedBox(
                width: 150, // Expand the image to fill the width
                height: 150.0, // Set your desired height
                
                child: ClipOval(
                  child: Image.network(
                    coverImageUrl,
                    fit: BoxFit.cover,
                    frameBuilder: (BuildContext context, Widget child, int? frame, bool wasSynchronouslyLoaded) {
                      if (frame == null) {
                        return const CircularProgressIndicator();
                      }
                      return child;
                    },
                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                      return const Icon(Icons.error); // You can customize error handling as needed.
                    },
                  ),
                ),
              ),
            ),
            // Rest of your profile items
            buildProfileItem('Name', profileData!['name']),
            buildProfileItem('Phone', profileData!['phone']),
            buildProfileItem('Bio', profileData!['bio']),
            buildProfileItem('Updated At', formatDateTime(profileData!['updated_at'])),
      
            GestureDetector(
              onTap: (){
                 Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditProfileScreen(),
                            ),
                          );
                        
              },
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  width: double.infinity,
                  height: 60,
                  color: Colors.deepPurple,
                  child: const Center(child: Text('Update',style: TextStyle(color: Colors.white),)),),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildProfileItem(String label, String? value) {
    return Column(
      children: [
        ListTile(
          title: Text('$label: ${value ?? 'N/A'}'),
        ),
      ],
    );
  }

  String formatDateTime(String dateTimeString) {
    final dateTime = DateTime.parse(dateTimeString);
    final formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
    return formattedDate;
  }
}
