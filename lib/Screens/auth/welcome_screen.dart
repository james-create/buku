import 'package:flutter/material.dart';
import 'package:buku/Screens/admin/root_screen.dart';
import 'package:buku/Screens/utils/token.dart';
import 'package:buku/Screens/auth/login_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTokenAndRedirect();
  }

  Future<void> _loadTokenAndRedirect() async {
    String token = await getTokenFromSharedPreferences();
    if (token.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const RootScreen(), // Redirect to RootScreen
        ),
      );
    } else {
      setState(() {
        isLoading = false; // Update isLoading when the token check is complete
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.deepPurple,
      appBar: AppBar(title: const Center(child: Text('WELCOME TO LEARNSTAR',style: TextStyle(color: Colors.white),)),automaticallyImplyLeading: false,
       backgroundColor: Colors.purple[900], // Set the background color to deep purple
      iconTheme: const IconThemeData(color: Colors.white), // Set icon color to white
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: isLoading // Show a loading indicator while checking the token
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: w,
                      height: h * 0.5,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage("images/welcome2.png"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          const Text(
                            "Learn Anytime And Anywhere",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Embark on a journey through a vast repository of online educational resources and treasures.",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton(
                            
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 30,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text(
                              'Get started',
                              style: TextStyle(
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.bold,
                  
                                fontSize: 26,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                    const Text(
                      'Powered by DeepnetLabs : Version 1',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
