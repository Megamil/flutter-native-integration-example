import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_module/screens/parameter_screen.dart';
import 'package:flutter_module/screens/simple_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Module',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const _SplashScreen(),
    );
  }
}

class _SplashScreen extends StatefulWidget {
  const _SplashScreen({Key? key}) : super(key: key);

  @override
  __SplashScreenState createState() => __SplashScreenState();
}

class __SplashScreenState extends State<_SplashScreen> {
  final MethodChannel _channel = const MethodChannel('br.com.megamil/callSDK');

  Future<dynamic> _initializeApp(MethodCall call) async {

    switch (call.method) {
      case 'newUser':
        final jsonString = call.arguments;
        final data = jsonDecode(jsonString);
        final gender = data['gender'];
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => RandomUserScreen(gender: gender, platform: _channel,),
          ),
        );
        break;
      default:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const SampleScreen()
          ),
        );
        break;
    }

  }

  @override
  void initState() {
    super.initState();
    _channel.setMethodCallHandler(_initializeApp);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}