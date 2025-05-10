import 'package:book_frontend/api/book_service.dart';
import 'package:book_frontend/model/book.dart';
import 'package:book_frontend/widget/book_card_widget.dart';
import 'package:book_frontend/widget/custom_app_bar.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final BookService bookService = BookService();

  final List<String> categories = [
    'All',
    'New Releases',
    'Coming Soon',
    'Deals',
  ];
  String selectedCategory = 'All';

  late Future<List<Book>> futureBooks;

  @override
  void initState() {
    super.initState();
    futureBooks = bookService.getBooksByCategory(
      selectedCategory.toLowerCase(),
    );
  }

  void _onCategoryChanged(String? category) {
    if (category == null) return;

    setState(() {
      selectedCategory = category;
      futureBooks = bookService.getBooksByCategory(category.toLowerCase());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        isLoggedIn: true,
        activeRoute: 'home',
        onCatalogPressed: () => Navigator.pushNamed(context, '/catalog'),
        onBookmarkPressed: () => Navigator.pushNamed(context, '/bookmarks'),
        onCartPressed: () => Navigator.pushNamed(context, '/cart'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Discover Books',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                DropdownButton<String>(
                  value: selectedCategory,
                  items:
                      categories.map((String category) {
                        return DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                  onChanged: _onCategoryChanged,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Explore our collection of curated titles',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: FutureBuilder<List<Book>>(
                future: futureBooks,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoading();
                  } else if (snapshot.hasError) {
                    return _buildError(snapshot.error.toString());
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmpty();
                  }

                  final books = snapshot.data!;

                  return GridView.builder(
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: books.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 2.0,
                        ),
                    itemBuilder: (context, index) {
                      return BookCard(book: books[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Colors.black),
          const SizedBox(height: 16),
          Text(
            'Loading collection...',
            style: TextStyle(color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.grey[700]),
          const SizedBox(height: 16),
          Text(
            'Unable to load books',
            style: TextStyle(color: Colors.grey[800], fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(message, style: TextStyle(color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No books found',
            style: TextStyle(color: Colors.grey[800], fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new titles',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
