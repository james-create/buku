import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  Future<void> _launchWebsite() async {
    final Uri url = Uri.parse('https://deepnet.co.ke/');
    if (!await canLaunch(url.toString())) {
      throw Exception('Could not launch $url');
    }
    await launch(url.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(title: const Text('Help center',style: TextStyle(color: Colors.white),),
     
        backgroundColor: Colors.deepPurple, // Set the background color to deep purple
    iconTheme: const IconThemeData(color: Colors.white), 
     ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildContactItemWithShadow(
            onTap: (){},
            icon: Icons.email,
            contact: 'info@deepnet.co.ke',
            description: 'For email support and inquiries. We usually respond within 24 hours.',
          ),
          _buildContactItemWithShadow(
                  onTap: (){},
            icon: Icons.phone,
            contact: '+254 741481050, +254706537241',
            description: 'For phone support during business hours. Monday to Friday, 9 AM - 5 PM.',
          ),
          _buildContactItemWithShadow(
                  onTap: (){},
            icon: Icons.chat,
            contact: 'Live Chat Support',
            description: 'Connect with us through live chat on our website. Instant assistance!',
          ),
          _buildContactItemWithShadow(
                  onTap: (){},
            icon: Icons.info,
            contact: 'FAQs',
            description: 'Visit our FAQ section on the website for answers to common questions.',
          ),
          _buildContactItemWithShadow(
            icon: Icons.web,
            contact: 'Website',
            description: 'www.learnstar.deepnet.co.ke',
            onTap: (){},
          ),
        ],
      ),
    );
  }

  Widget _buildContactItemWithShadow({
    required IconData icon,
    required String contact,
    required String description,
    required Function()? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ListTile(
        leading: Icon(icon),
        title: Text(contact),
        subtitle: Text(description),
        onTap: onTap,
      ),
    );
  }
}
