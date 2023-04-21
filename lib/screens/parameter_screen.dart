import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class RandomUserScreen extends StatefulWidget {
  final String gender;
  final MethodChannel platform;
  const RandomUserScreen({Key? key, required this.gender, required this.platform}) : super(key: key);

  @override
  _RandomUserScreenState createState() => _RandomUserScreenState();
}

class _RandomUserScreenState extends State<RandomUserScreen> {
  Future<Map<String, dynamic>>? _futureUserData;
  late String apiResponse;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final response =
    await http.get(Uri.parse('https://randomuser.me/api/?gender=${widget.gender}'));

    if (response.statusCode == 200) {
      apiResponse = response.body;
      final userData = jsonDecode(response.body)['results'][0];
      setState(() {
        _futureUserData = Future.value(userData);
      });
    } else {
      throw Exception('Failed to load user data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuário criado'),
      ),
      body: Center(
        child: _futureUserData != null
            ? FutureBuilder<Map<String, dynamic>>(
          future: _futureUserData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              final userData = snapshot.data!;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.network(
                    userData['picture']['large'],
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '${userData['name']['first']} ${userData['name']['last']}',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'E-mail: ${userData['email']}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Telefone: ${userData['phone']}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Cidade: ${userData['location']['city']}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Recebido: ${widget.gender}',
                    style: const TextStyle(fontSize: 10),
                  ),
                ],
              );
            } else {
              return const CircularProgressIndicator();
            }
          },
        )
            : Container(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          debugPrint("FloatingActionButton Clicked");
          SystemNavigator.pop(animated: true);
          widget.platform.invokeMethod("userCreated", apiResponse);
        },
        child: const Icon(Icons.arrow_back),
      ),
    );
  }
}
