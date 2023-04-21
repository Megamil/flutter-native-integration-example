import 'package:flutter/material.dart';

class SampleScreen extends StatelessWidget {
  const SampleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
            "Tela simples",
            style: TextStyle(fontSize: 40)
        )
      ),
    );
  }
}
