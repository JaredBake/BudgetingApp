import 'dart:convert'; // For JSON encoding/decoding

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'pages/welcome.dart';
import 'pages/home.dart';
import 'pages/accounts.dart';
import 'pages/transactions.dart';
import 'pages/funds.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Budgeting App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: WelcomePage(),
        routes: {
          '/home': (context) {
            final user = ModalRoute.of(context)?.settings.arguments as User;
            return Home(user: user);
          },
          '/accounts': (context) {
            final user = ModalRoute.of(context)?.settings.arguments as User;
            return AccountsPage(user: user);
          },
          '/transactions': (context) {
            final user = ModalRoute.of(context)?.settings.arguments as User;
            return TransactionsPage(user: user);
          },
          '/funds': (context) {
            final user = ModalRoute.of(context)?.settings.arguments as User;
            return FundsPage(user: user);
          },
        },
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
}

Future<void> fetchPosts() async {
  final response = await http.get(Uri.parse('http://localhost:5284/test'));

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    print('GET Response: $data');
    print('HTTP GET test successful with budget app on localhost:5284');
  } else {
    print('GET Request failed with status: ${response.statusCode}');
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    return Scaffold(
      body: Column(
        children: [
          Text('A random idea:'),
          Text(appState.current.asLowerCase),
          Text('A random change added hot 3'),

          ElevatedButton(
            onPressed: () {
              print('button pressed!');
            },
            child: Text('Next'),
          ),

          ElevatedButton(
            onPressed: () {
              fetchPosts();
            },
            child: Text('HTTP test'),
          ),
        ],
      ),
    );
  }
}
