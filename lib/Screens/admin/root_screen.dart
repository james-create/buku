
import 'dart:convert';

import 'package:buku/Screens/admin/GraphScreen.dart';
import 'package:buku/Screens/admin/categories_screen.dart';
import 'package:buku/Screens/admin/help_screen.dart';
import 'package:buku/Screens/admin/home_screen.dart';
import 'package:buku/Screens/admin/profile_screen.dart';
import 'package:buku/Screens/admin/send_message_screen.dart';
import 'package:buku/Screens/admin/sub_statistiic.dart';
import 'package:buku/Screens/admin/subscription_screen.dart';
import 'package:buku/Screens/admin/transactions_screen.dart';
import 'package:buku/Screens/admin/users_screen.dart';
import 'package:buku/Screens/admin/wish_list.dart';
import 'package:buku/Screens/auth/welcome_screen.dart';
import 'package:buku/Screens/utils/constarts.dart';
import 'package:buku/Screens/utils/show_custom_error_message.dart';
import 'package:buku/Screens/utils/token.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;



class RootScreen extends StatefulWidget {
  const RootScreen({super.key});
  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  int currentPage = 0;
  List<Widget> pages= const [
    HomeScreen(),
    ProfileScreen(),
    WishListScreen(),
    SubscriptionScreen(),
    // SettingScreen()
  ];


 String token = '';
  bool isLoading = false;
  bool isUserLoading = false;
  bool isLoadingLogout = false;

  
  int userRoleId =0;
  String name ='';
  String email ='';
  String username ='';


   Future<void> _loadToken() async {
    String storedToken = await getTokenFromSharedPreferences();
    setState(() {
      token = storedToken;
    });
     user();
  }



    // check user role :
 Future<void> user() async {
     setState(() {
      isUserLoading = true;
    });
    var apiUrl =  '$appApiUrl/user'; // Use widget.bookId
    final Map<String, String> headers = {
      'Authorization': 'Bearer $token',
    };
    try {
     final response = await http.get(Uri.parse(apiUrl), headers: headers);
      if (response.statusCode == 200) {
    final jsonResponse = json.decode(response.body);
      // Access the 'user' object and get the 'role_id'
      final user = jsonResponse['user'];
      // Now you can use the roleId as needed
      setState(() {
        userRoleId= user['role_id'];
        name=user['name'];
         email=user['email'];
          username=user['username'];
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


@override
void initState() {
  super.initState();
  _loadToken();
 
}

    





  @override
  Widget build(BuildContext context) {




Future<void> fetchApiDataAndLogout() async {
  setState(() {
    isLoadingLogout = true; // Show loading indicator
  });

  // Wait for the token to be loaded
  await _loadToken();

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
      showCustomErrorMessage(context, 'Something went wrong');
       SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
    }
  } catch (e) {
    //  showCustomErrorMessage(context,'Exception: $e');
    showCustomErrorMessage(context, 'Network error. check your internet connection');
  } finally {
    setState(() {
      isLoadingLogout = false; // Hide loading indicator
    });
  }
}


  @override
  void initState() {
    super.initState();
    _loadToken();
  }






    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(

   appBar: AppBar(
    title: isLoadingLogout
        ? const Center(child: Text('Signing out bye ...',style: TextStyle(color: Colors.white)))
        : const Center(child: Text('LEARN STAR',style: TextStyle(color: Colors.white),)),
    actions: [
      IconButton(
        onPressed: () {
          fetchApiDataAndLogout();
        },
        icon: const Icon(Icons.logout_outlined),
      ),
    ],
    backgroundColor: Colors.deepPurple, // Set the background color to deep purple
    iconTheme: const IconThemeData(color: Colors.white), // Set icon color to white
  ),

drawer: Drawer(
  child: Column(
    children: <Widget>[
      Expanded(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 0.2),
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.deepPurple,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.account_circle, // Replace with the desired icon
                    size: 80, // Adjust the size of the icon as needed
                    color: Colors.white,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'LearnStar', // Replace with the user's username
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                    ),
                  ),
                ],
              ),
            ),


                ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
               Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RootScreen()),
              );
              },
            ),


          
            ListTile(
              leading: const Icon(Icons.handshake),
              title: Text('$name, Email : $email ,User : $username'),
              onTap: () {
               Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RootScreen()),
              );
              },
            ),
        


        ListTile(
              leading: const Icon(Icons.list),
              title: const Text('Categories'),
              onTap: () {
               Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CategoryScreen()),
              );
              },
            ),




           ListTile(
              leading: const Icon(Icons.help_center),
              title: const Text('Help center'),
              onTap: () {
               Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HelpScreen()),
              );
              },
            ),
        




                userRoleId == 1 ?
            ListTile(
            leading: const Icon(Icons.bar_chart),
            title: const Text('Graph User(s) & Book(s) '), // Call the API to log out
            onTap: ()
            {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>  const GraphScreen()),
              );
            },
            ):const Text(''),

            userRoleId == 1 ?
            ListTile(
            leading: const Icon(Icons.person_search_rounded),
            title: const Text('Users App & Website'), // Call the API to log out
            onTap: ()
            {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UsersScreen()),
              );
            },
            )
            :  const Text(''),



    

            userRoleId == 1 ?
            ListTile(
              leading: const Icon(Icons.monetization_on_sharp),
              title: const Text('Mpesa Transactions'), // Call the API to log out
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) =>  const TransactionScreen()),
                );
              },
            ) :const Text(''),
            userRoleId == 1 ?
              ListTile(
                leading: const Icon(Icons.assessment),
                title: const Text('Subscription statistics'), // Call the API to log out
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  const SubStatistics()),
                  );
                },
              ) :const Text(''),



            // ListTile(
            //   leading: Icon(Icons.help_center),
            //   title: Text('Help center'),
            //   onTap: () {
            //    Navigator.push(
            //     context,
            //     MaterialPageRoute(builder: (context) => const HelpScreen()),
            //   );
            //   },
            // ),

     

          // ListTile(
          //   leading: Icon(Icons.exit_to_app),
          //   title: isLoadingLogout?Text('Signing you out bye...'):Text('Sign Out'),
          //   onTap: fetchApiDataAndLogout, // Call the API to log out
          //   ),


          ],
        ),
      ),
          Align(
        alignment: Alignment.bottomCenter,
        child: ListTile(
          leading: const Icon(Icons.exit_to_app),
          title: isLoadingLogout ? const Text('Signing you out bye...') : const Text('Sign Out'),
          onTap: fetchApiDataAndLogout,
        ),
      ),
     Container(
      width: w * 1,
      padding: const EdgeInsets.all(2.0),
      color: Colors.deepPurple,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center, // Center the children horizontally
        children: <Widget>[
          Container(
            width: w * 0.09,
            height: h * 0.09,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("images/deepnet.png"),
              ),
            ),
          ),
            const Text(
            '  DEEPNET-LABS',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ],
      ),
    )

    ],
  ),
),


      body: pages[currentPage],
      floatingActionButton: FloatingActionButton(
          onPressed: () {
             Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SendMessageScreen()),
            );
          },
          child: const Icon(Icons.message_outlined)),
          bottomNavigationBar: NavigationBar(
            destinations: const [
              NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
              NavigationDestination(icon: Icon(Icons.person_4), label: 'Profile'),
              NavigationDestination(icon: Icon(Icons.favorite), label: 'Favorites'),
              // NavigationDestination(icon: Icon(Icons.search_off_outlined), label: 'Settings'),
              NavigationDestination(icon: Icon(Icons.money_rounded), label: 'Subscription'),
              // NavigationDestination(icon: Icon(Icons.settings), label: 'Settings'),
            ],
            onDestinationSelected: (int index){
              setState(() {
                 currentPage=index;
              });
            },
            selectedIndex: currentPage,
          ),
    );
  }
}
