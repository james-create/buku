import 'dart:convert';
import 'package:buku/Screens/admin/root_screen.dart';
import 'package:buku/Screens/utils/constarts.dart';
import 'package:buku/Screens/utils/custom_snacable.dart';
import 'package:buku/Screens/utils/token.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool hasActiveSubscription = false;
  String token = '';
  Map<String, dynamic> responseData = {};
  bool isLoading = false;
  bool isSubmitLoading = false;
  String phone = '';
  int amount = 0;


   int days = 0;
   String due_date ='';
   double price = 0;
   
  int min_amount = 0;


  String errorMessage = '';
  String customerMessage = '';


  bool old_payment_state=false;
  bool new_payment_state=false;

 

  TextEditingController phoneController = TextEditingController();
  TextEditingController amountController = TextEditingController();

 bool shouldRefresh = false;

  Future<void> _loadToken() async {
    setState(() {
      isLoading = true;
    });
    // Replace this with your implementation
    String storedToken = await getTokenFromSharedPreferences();
    setState(() {
      token = storedToken;
    });
    fetchApiData();
    checkPaymentState(); 
  
  }



Future<void> checkPaymentState() async {
  try {
    final response = await http.get(
      Uri.parse('$appApiUrl/paid/state'), // Update the URL as needed
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      // print(response.body);

      // Print the values before comparison
      // print('Old Payment State: $old_payment_state');
      // print('New Payment State: ${responseData['state']}');

      setState(() {
        new_payment_state = responseData['state'];
      });
      // Check if payment state has changed
      if (old_payment_state != new_payment_state) {
        // If changed, refresh the page
        _loadToken();
        // Update old payment state
        old_payment_state = new_payment_state;
      }
    }
  } catch (e) {
    // print(e);
    //  ApiResponse.showSnackBar(context, 'Network error. Check your internet connection.');
  } finally {
    // Schedule the next execution after 5 seconds
    Future.delayed(const Duration(seconds: 5), () => checkPaymentState());
  }
}









Future<void> fetchApiData() async {
  setState(() {
    isLoading = true;
  });
  try {
    final response = await http.get(
      Uri.parse('$appApiUrl/paid'), // Update the URL as needed
      headers: {
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
        hasActiveSubscription = responseData['paid'];
        days = responseData['days'] ?? 0;
        due_date = responseData['due_date'] ?? '';
        price = responseData['price'] ?? 0;
        min_amount = int.tryParse(responseData['min_amount'].toString()) ?? 0;

        setState((){
          old_payment_state= responseData['paid'];
        });
    } 
  } catch (e) {
   ApiResponse.showSnackBar(context, 'Network error. Check your internet connection.');
  } finally {
    
    setState(() {
      isLoading = false;
    });
     
  }
}
















Future<void> makePayment() async {
  setState(() {
    isSubmitLoading = true;
  });
  try {
    final Map<String, dynamic> paymentData = {
      'phone': phone,
      'amount': amount,
   
    };
    final response = await http.post(
      Uri.parse('$appApiUrl/renewal'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(paymentData),
    );

   if (response.statusCode == 200) {
        responseData = json.decode(response.body);
    final errorMessage = responseData['errorMessage'];
    final customerMessage = responseData['CustomerMessage'];
    phoneController.clear();
    amountController.clear();

  setState(() {
    // Check if errorMessage is not null
    this.errorMessage = errorMessage ?? '';
    // Check if customerMessage is not null
    this.customerMessage = customerMessage ?? '';
  });
  } 
  } catch (e) {
       ApiResponse.showSnackBar(context, 'Network error. Check your internet connection.');
  } finally {
    setState(() {
      isSubmitLoading = false;
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
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                hasActiveSubscription ? Icons.check_circle : Icons.cancel,
                size: 50,
                color: hasActiveSubscription ? Colors.green : Colors.red,
              ),
              Center(
                child: isLoading
                    ? const CircularProgressIndicator()
                    : const Text(''),
              ),

              //  Image.asset('images/mpesa.png', width: 100, height: 100),
              Card(
                color: hasActiveSubscription ? Colors.green : Colors.red,
                elevation: 4, // Add elevation for a subtle shadow
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        hasActiveSubscription
                            ? 'You have an active subscription until $due_date. You renewed for $days days at KES ${(days * (10 / 3)).toStringAsFixed(0)}'
                            : 'Your subscription is inactive.',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // Text color contrasting with the card background
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8), // Add some spacing between the text and other potential content
                      // You can add more widgets here based on your design requirements
                    ],
                  ),
                ),
              ),

              Text(
                hasActiveSubscription
                    ? 'You can now access our online books and resources.'
                    : 'Renew your subscription to access our online books and resources. Use Mpesa for payment',
                style: const TextStyle(
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
              if (!hasActiveSubscription)
                Column(
                  children: [
                    Image.asset('images/mpesa.png', width: 120, height: 120),
  Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    const Text(
      'Plans and Details:',
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    ),
    const SizedBox(height: 2),
    const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '1. ',
          style: TextStyle(
            fontSize: 12,
          ),
        ),
        Expanded(
          child: Text(
            'Gold Plan: Customizable duration starting at 100 KES per month',
            style: TextStyle(
              fontSize: 10,
              color: Colors.black,
              overflow: TextOverflow.ellipsis, // Handling overflow
            ),
          ),
        ),
      ],
    ),
    const Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '2. ',
          style: TextStyle(
            fontSize: 12,
          ),
        ),
        Expanded(
          child: Text(
            'Silver Plan: Customizable duration starting at 50 KES',
            style: TextStyle(
              fontSize: 10,
              color: Colors.black,
              overflow: TextOverflow.ellipsis, // Handling overflow
            ),
          ),
        ),
      ],
    ),
    Text(
      '3. Estimated cost per day: ${(100 / 30).toStringAsFixed(0)} KES for any plan',
      style: const TextStyle(
        fontSize: 10,
      ),
    ),
  ],
),
  const Text(
      'Access the entire e-book collection (excluding premium and newly released books).',
      style: TextStyle(
        fontSize: 10,
      ),
    ),

  const Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      'Step-by-Step Payment Guide:',
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
    ),
    SizedBox(height: 8),
    Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '1. ',
          style: TextStyle(
            fontSize: 12,
          ),
        ),
        Expanded(
          child: Text(
            'Enter your safaricom phone number in this formart 254XXXXXXXXX',
            style: TextStyle(
              fontSize: 10,
              color: Colors.black,
              overflow: TextOverflow.ellipsis, // Handling overflow
            ),
          ),
        ),
      ],
    ),
    Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '2. ',
          style: TextStyle(
            fontSize: 12,
          ),
        ),
        Expanded(
          child: Text(
            'Enter amount you want to subscribe for',
            style: TextStyle(
              fontSize: 10,
              color: Colors.black,
              overflow: TextOverflow.ellipsis, // Handling overflow
            ),
          ),
        ),
      ],
    ),
    Text(
      '3. Click on "Renew my Subscription" ',
      style: TextStyle(
        fontSize: 10,
      ),
    ),
     Text(
      '4. You will receive a Pop up for payment in your phone',
      style: TextStyle(
        fontSize: 10,
      ),
    ),
     Text(
      '5. Enter your PIN',
      style: TextStyle(
        fontSize: 10,
      ),
    ),
      Text(
      '6. After Transaction is complete click Back',
      style: TextStyle(
        fontSize: 10,
      ),
    ),
  ],
),


   const SizedBox(height: 10,),




               
  Visibility(
  visible: customerMessage.isNotEmpty || errorMessage.isNotEmpty,
  child: Container(
    width: double.infinity,
    color: Colors.white70,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (customerMessage.isNotEmpty)
          Container(
            color: Colors.green,
            padding: const EdgeInsets.all(8),
            width: double.infinity,
            child: Text(
              '$customerMessage check your phone to confirm payment to complete your renewal process',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        if (errorMessage.isNotEmpty)
          Container(
            color: Colors.red,
            padding: const EdgeInsets.all(8),
            width: double.infinity,
            child: Text(
              errorMessage,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
      ],
    ),
  ),
),
TextFormField(
  controller: phoneController,
  decoration: const InputDecoration(
    labelText: 'Enter Phone (254XXXXXXXXX)',
    enabledBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.grey), // Customize the underline color
    ),
    focusedBorder: UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.blue), // Customize the focused underline color
    ),
  ),
  onChanged: (value) {
    setState(() {
      phone = value; // Update 'phone' when text changes
    });
  },
),
const SizedBox(height: 5),
TextFormField(
  controller: amountController,
  decoration: InputDecoration(
    labelText: 'Renewal amount >= KES $min_amount',
    enabledBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.grey), // Customize the underline color
    ),
    focusedBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: Colors.blue), // Customize the focused underline color
    ),
  ),
onChanged: (value) {
  setState(() {
    // Validate the input to ensure it's a number and greater than or equal to 100
    int parsedValue = int.tryParse(value) ?? 0;
    amount = parsedValue;
  });
}

),


                    const SizedBox(height: 20),
        SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    onPressed: () {
      makePayment();
    },
    child: isSubmitLoading
        ? const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 10),
              Text(
                'Payment initiated Loading...',
                style: TextStyle(fontSize: 16),
              ),
            ],
          )
        : const Text(
            'Renew my subscription',
            style: TextStyle(fontSize: 16),
          ),
  ),
),

                  ],
                ),

                    const SizedBox(height: 30),
                    GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RootScreen(),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Container(
                        width: double.infinity,
                        height: 39,
                        color: Colors.orange,
                        child: const Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(Icons.arrow_back_ios_new, color: Colors.white), // Icon added here
                              SizedBox(width: 8), // Adds space between icon and text
                              Text('Back', style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

          
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: SubscriptionScreen(),
  ));
}
