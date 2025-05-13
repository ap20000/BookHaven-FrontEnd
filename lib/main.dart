import 'package:book_frontend/screens/add_review_page.dart';
import 'package:book_frontend/screens/admin/author_management_page.dart';
import 'package:book_frontend/screens/admin/book_management_page.dart';
import 'package:book_frontend/screens/admin/genre_management_page.dart';
import 'package:book_frontend/screens/admin/publisher_page.dart';
import 'package:book_frontend/screens/cart_item_screen.dart';
import 'package:book_frontend/screens/catalog_page.dart';
import 'package:book_frontend/screens/staff/claim_process_page.dart';
import 'package:book_frontend/screens/home_page.dart';
import 'package:book_frontend/screens/login_page.dart';
import 'package:book_frontend/screens/register_page.dart';
import 'package:book_frontend/screens/user_order_page.dart';
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
        '/cart': (context) => const CartPage(),
        '/books': (context) => BookManagementPage(),
        '/publishers': (context) => const PublisherPage(),
        '/genres': (context) => const GenreManagementPage(),
        '/authors': (context) => const AuthorManagementPage(),
        '/orders-list': (context) => const UserOrdersPage(),
        '/claim-process': (context) => const ClaimProcessPage(),
      },
    );
  }
}
