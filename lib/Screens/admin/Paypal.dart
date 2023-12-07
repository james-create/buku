import 'package:flutter/material.dart';

class Paypal extends StatefulWidget {
  const Paypal({super.key});

  @override
  State<Paypal> createState() => _PaypalState();
}

class _PaypalState extends State<Paypal> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pay'),),
    );
  }
}