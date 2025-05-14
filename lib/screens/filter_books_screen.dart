import 'package:book_frontend/api/auth_service.dart';
import 'package:book_frontend/api/book_service.dart';
import 'package:book_frontend/model/book.dart';
import 'package:book_frontend/widget/custom_app_bar.dart';
import 'package:flutter/material.dart';

class FilteredBooksScreen extends StatefulWidget {
  @override
  _FilteredBooksScreenState createState() => _FilteredBooksScreenState();
}

class _FilteredBooksScreenState extends State<FilteredBooksScreen> {
  final BookService _bookService = BookService();
  List<Book> _books = [];
  bool _isLoading = false;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _languageController = TextEditingController();
  String _sortBy = 'title';
  String _sortDirection = 'asc';

  Future<void> _fetchBooks() async {
    setState(() => _isLoading = true);

    try {
      final books = await _bookService.filterBooks(
        title: _titleController.text,
        language: _languageController.text,
        sortBy: _sortBy,
        sortDirection: _sortDirection,
      );
      setState(() => _books = books);
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load books')));
    }

    setState(() => _isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    _fetchBooks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        isLoggedIn: true,
        activeRoute: 'catalog',
        onHomePressed: () => Navigator.pushNamed(context, '/home'),
        onBookmarkPressed: () => Navigator.pushNamed(context, '/bookmarks'),
        onCartPressed: () => Navigator.pushNamed(context, '/cart'),
        onLogoutPressed: () async {
          final auth = AuthService();
          await auth.logout();
          Navigator.pushReplacementNamed(context, '/login');
        },
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child:
                _isLoading
                    ? Center(child: CircularProgressIndicator())
                    : _books.isEmpty
                    ? Center(child: Text('No books found'))
                    : ListView.builder(
                      itemCount: _books.length,
                      itemBuilder: (context, index) {
                        final book = _books[index];
                        return ListTile(
                          title: Text(book.title),
                          subtitle: Text('${book.language} | ${book.format}'),
                          trailing: Text('\$${book.price.toStringAsFixed(2)}'),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: 'Title'),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _languageController,
                  decoration: InputDecoration(labelText: 'Language'),
                ),
              ),
            ],
          ),
          Row(
            children: [
              DropdownButton<String>(
                value: _sortBy,
                items:
                    ['title', 'price', 'date']
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text('Sort by $e'),
                          ),
                        )
                        .toList(),
                onChanged: (value) => setState(() => _sortBy = value!),
              ),
              SizedBox(width: 10),
              DropdownButton<String>(
                value: _sortDirection,
                items:
                    ['asc', 'desc']
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: Text(e.toUpperCase()),
                          ),
                        )
                        .toList(),
                onChanged: (value) => setState(() => _sortDirection = value!),
              ),
              Spacer(),
              ElevatedButton(
                onPressed: _fetchBooks,
                child: Text('Apply Filters'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
