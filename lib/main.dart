import 'package:book_frontend/screens/catalog_page.dart';
import 'package:book_frontend/screens/home_page.dart';
import 'package:book_frontend/screens/login_page.dart';
import 'package:book_frontend/screens/register_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BookHaven',
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/home': (context) => HomePage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => RegisterPage(),
        '/catalog': (context) => const CatalogPage(),
      },
    );
  }
}
