import 'package:book_frontend/widget/custom_app_bar.dart';
import 'package:flutter/material.dart';

class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        isLoggedIn: true, // or false based on your auth state
        activeRoute: 'catalog',
        onHomePressed: () => Navigator.pushNamed(context, '/home'),
        onBookmarkPressed: () => Navigator.pushNamed(context, '/bookmarks'),
        onCartPressed: () => Navigator.pushNamed(context, '/cart'),
      ),
      body: const Center(child: Text('Catalog Page Content')),
    );
  }
}
