import 'package:buku/Screens/admin/root_screen.dart';
import 'package:buku/Screens/auth/welcome_screen.dart';
import 'package:buku/Screens/utils/constarts.dart';
import 'package:buku/Screens/utils/show_custom_error_message.dart';
import 'package:buku/Screens/utils/token.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class NavScreen extends StatefulWidget {
  const NavScreen({super.key});
  @override
  State<NavScreen> createState() => _NavScreenState();
}


class _NavScreenState extends State<NavScreen> {
  String token = '';
  bool isLoading = false;

  Future<void> _loadToken() async {
    String storedToken = await getTokenFromSharedPreferences();
    setState(() {
      token = storedToken;
    });
  }

  Future<void> fetchApiDataAndLogout() async {
    setState(() {
      isLoading = true; // Show loading indicator
    });

    String apiUrl = "$appApiUrl/logout";
    final Map<String, String> headers = {
      'Authorization': 'Bearer $token',
    };

    try {
      final response = await http.post(Uri.parse(apiUrl), headers: headers);
      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        // ignore: use_build_context_synchronously
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
        );
      } else {
        // Handle error response here
        // print(response.body);
        showCustomErrorMessage(context, 'Something went wrong');

      }
    } catch (e) {
        //  showCustomErrorMessage(context,'Exception: $e');
        showCustomErrorMessage(context, 'Network error. check your internet connection');

    } finally {
      setState(() {
        isLoading = false; // Hide loading indicator
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
      appBar: AppBar(
      title: const Text('NAVIGATION'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_outlined),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RootScreen()),
          );
        },
      ),
    ),
      body: ListView(
        children: [
          // ... other ListTiles ...
            ListTile(
            title: const Text('Home'),
            leading: const Icon(Icons.home), // Logout icon
            onTap: () {
            Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RootScreen()),
            );
                        },
          ),
            ListTile(
            title: const Text('Logout'),
            leading: const Icon(Icons.exit_to_app), // Logout icon
            onTap: fetchApiDataAndLogout, // Call the API to log out
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(home: NavScreen()));
}
