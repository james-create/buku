import 'package:flutter/material.dart';
// Import the http package

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool useFingerprint = false; // State variable to track fingerprint usage
  
  // Function to send the updated status to the server
  Future<void> sendStatusToServer(bool status) async {
    print(useFingerprint);
    // final url = Uri.parse('https://your-server-url.com/api/updateFingerprintStatus');
    // final response = await http.post(
    //   url,
    //   body: {'useFingerprint': status.toString()},
    // );

    // if (response.statusCode == 200) {
    //   print('Status sent to server successfully.');
    // } else {
    //   print('Failed to send status to server. Error: ${response.statusCode}');
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Use Fingerprint when opening the app',
              style: TextStyle(fontSize: 18.0),
            ),
            Switch(
              value: useFingerprint,
              onChanged: (newValue) async {
                setState(() {
                  useFingerprint = newValue;
                });

                // When the switch is toggled, update the state and send it to the server.
                await sendStatusToServer(useFingerprint);
              },
            ),
          ],
        ),
      ),
    );
  }
}
