import 'dart:convert'; // For JSON encoding/decoding

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';

import 'pages/welcome.dart';
import 'pages/home.dart';
import 'pages/accounts.dart';
import 'pages/transactions.dart';
import 'pages/funds.dart';

import 'package:flutter_application/models/data.dart';
import 'package:flutter_application/models/credentials.dart';

import '../api/auth_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> userLoggedIn() async {
    WidgetsFlutterBinding.ensureInitialized();
    await initLocalStorage();

    if (localStorage.getItem('token')!.isNotEmpty) {
      print('User logged in already');
      return true;
    };
    print ('User not logged in');
    return false;
  } 

  Future<User?> _getInitialRoute() async {
    if (await userLoggedIn()) {
      print('Attempting to get user');
      try {
        final user = await AuthService.getUser();
    
        final credentials = Credentials(
          userId: user['id'],
          name: user['credentials']?['name'] ?? '',
          userName: user['credentials']?['userName'] ?? '',
          email: user['credentials']?['email'] ?? '',
        );

        User userObject = User(
          createdAt: DateTime.parse(user['createdAt']),
          credentials: credentials,
          data: Data(funds: [], accounts: [])
        );

        print(userObject);

        return userObject;    
      } catch (e) {
        print ('Error loading user: $e');
        return null;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Budgeting App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        ),
        home: FutureBuilder<User?>(
          future: _getInitialRoute(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator()
                )
              );
            }

            if (snapshot.hasError) {
              print(snapshot.error);
              print('Snapshot had error');
              return WelcomePage();
            }

            if (snapshot.hasData && snapshot.data != null) {
              print('Routing home');
              return Home(user: snapshot.data!);
            } else {
              print('something else');
              return WelcomePage();
            }
          }
        ),
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
