import 'dart:io';
import 'package:buku/Screens/admin/root_screen.dart';
import 'package:buku/Screens/utils/constarts.dart';
import 'package:buku/Screens/utils/custom_snacable.dart';
import 'package:buku/Screens/utils/token.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
    bool isLoading = false;
  File? _image;
  final picker = ImagePicker();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  // get token 
  String token = '';
  // bool isLoading = false;
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
  }


  Future<void> _getImageFromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _getImageFromGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }



Future<void> _uploadProfile() async {
  setState(() {
    isLoading=true;
  });
  // Validate form input
  // if (_nameController.text.isEmpty) {
  //   ApiResponse.showSnackBar(context, 'Please enter your name', isError: true);
  //   return;
  // }

  if (_image == null) {
    ApiResponse.showSnackBar(context, 'Please select an image', isError: true);
    return;
  }

  // url
  final apiUrl = '$appApiUrl/update/profile';
  var url = Uri.parse(apiUrl);
  final request = http.MultipartRequest('POST', url);

  // Add the image file to the request
  request.files.add(await http.MultipartFile.fromPath('image', _image!.path));

  // Add other fields as text fields
  request.fields['name'] = _nameController.text;
  request.fields['phone'] = _phoneController.text;
  request.fields['bio'] = _bioController.text;

  // Add authorization token to the request header
  request.headers['Authorization'] = 'Bearer $token';

  try {
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200) {
    setState(() {
    isLoading=false;
  });
      // Handle success
  ApiResponse.showSnackBar(context, 'Profile updated successfully');
  Navigator.push(
  context,
  MaterialPageRoute(
 builder: (context) => const RootScreen(),
                      ),
                    );

      // Clear form fields
      _nameController.clear();
      _phoneController.clear();
      _bioController.clear();
      setState(() {
        _image = null;
      });


    } else {
      // Handle errors
      ApiResponse.showSnackBar(context, 'Profile update failed with status code ${response.statusCode}', isError: true);
    }
  } catch (e) {
    // Handle network or other errors
     ApiResponse.showSnackBar(context, 'Error: $e', isError: true);
  }
}





  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('My Profile  ',style: TextStyle(color: Colors.white),),
     
        backgroundColor: Colors.deepPurple, // Set the background color to deep purple
    iconTheme: const IconThemeData(color: Colors.white), 
     ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (BuildContext context) {
                    return SafeArea(
                      child: Wrap(
                        children: <Widget>[
                          ListTile(
                            leading: const Icon(Icons.camera),
                            title: const Text('Take a Photo'),
                            onTap: () {
                              _getImageFromCamera();
                              Navigator.of(context).pop();
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.photo),
                            title: const Text('Choose from Gallery'),
                            onTap: () {
                              _getImageFromGallery();
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: CircleAvatar(
                radius: 60.0,
                backgroundColor: Colors.grey,
                backgroundImage: _image != null ? FileImage(_image!) : null,
                child: _image == null
                    ? const Icon(
                        Icons.camera_alt,
                        size: 40.0,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Enter your name',
              ),
            ),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone',
                hintText: 'Enter your phone number',
              ),
            ),
            TextField(
              controller: _bioController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Bio',
                hintText: 'Tell something about yourself',
              ),
            ),
            const SizedBox(height: 16.0),
         
            ElevatedButton(
              onPressed: () {
                _uploadProfile();
              },
              child: SizedBox(
                width: double.infinity,
                height: 30,
                child: Center(child: isLoading ? const Text('Save changes') : const Text('Loading...')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
