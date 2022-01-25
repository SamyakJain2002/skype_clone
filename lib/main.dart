import 'package:skype/provider/image_upload_provider.dart';
import 'package:skype/provider/user_provider.dart';
import 'package:skype/screens/search_screen.dart';
import 'package:provider/provider.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:skype/resources/auth_methods.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AuthMethods _authMethods = AuthMethods();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ImageUploadProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'Skype Clone',
        initialRoute: '/',
        routes: {
          '/search_screen': (context) => const SearchScreen(),
        },
        theme: ThemeData(brightness: Brightness.dark),
        home: (_authMethods.getCurrentUser() != null)
            ? HomeScreen()
            : LoginScreen(),
      ),
    );
  }
}
