import 'package:book_frontend/api/author_service.dart';
import 'package:book_frontend/api/book_service.dart';
import 'package:book_frontend/api/genre_service.dart';
import 'package:book_frontend/api/publisher_service.dart';
import 'package:book_frontend/model/author.dart';
import 'package:book_frontend/model/book.dart';
import 'package:book_frontend/model/genre.dart';
import 'package:book_frontend/model/publisher.dart';
import 'package:book_frontend/widget/admin_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class BookManagementPage extends StatefulWidget {
  const BookManagementPage({Key? key}) : super(key: key);

  @override
  State<BookManagementPage> createState() => _BookManagementPageState();
}

class _BookManagementPageState extends State<BookManagementPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final GenreService _genreService = GenreService();
  final AuthorService _authorService = AuthorService();
  final PublisherService _publisherService = PublisherService();
  final BookService _bookService = BookService();

  // Form controllers
  final _titleController = TextEditingController();
  final _isbnController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _languageController = TextEditingController();
  final _formatController = TextEditingController();

  // Form state
  int? _publisherID;
  final String _applicationUserId = "6f931d04-d44e-4fa7-84cb-9b4475a7c78c";
  bool _isOnSale = false;
  DateTime? _publicationDate;
  DateTime? _saleStartDate;
  DateTime? _saleEndDate;
  List<Object> _selectedGenreIDs = [];
  List<Object> _selectedAuthorIDs = [];
  int? _editingBookId;

  // Data lists
  List<Genre> _genres = [];
  List<Author> _authors = [];
  List<Publisher> _publishers = [];
  List<Book> _books = [];

  // UI state
  bool _isLoading = false;
  bool _isSubmitting = false;
  bool _isLoadingBooks = false;
  bool _isLoadingBookDetails = false;
  late TabController _tabController;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _isbnController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _languageController.dispose();
    _formatController.dispose();
    super.dispose();
  }

  // Fetch reference data (genres, authors, publishers)
  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final genresFuture = _genreService.getAllGenres();
      final authorsFuture = _authorService.getAllAuthors();
      final publishersFuture = _publisherService.getAllPublishers();

      final results = await Future.wait([
        genresFuture,
        authorsFuture,
        publishersFuture,
      ]);

      setState(() {
        _genres = List<Genre>.from(results[0]);
        _authors = List<Author>.from(results[1]);
        _publishers = List<Publisher>.from(results[2]);
        _isLoading = false;
      });

      // Fetch books after getting reference data
      _fetchBooks();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: $e'),
            backgroundColor: Colors.red[800],
          ),
        );
      }
    }
  }

  // Fetch all books
  Future<void> _fetchBooks() async {
    setState(() {
      _isLoadingBooks = true;
    });

    try {
      final books = await _bookService.getAllBooks();
      setState(() {
        _books = books;
        _isLoadingBooks = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingBooks = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading books: $e'),
            backgroundColor: Colors.red[800],
          ),
        );
      }
    }
  }

  // Date picker helper
  Future<void> _selectDate(
    BuildContext context,
    DateTime? initialDate,
    Function(DateTime) onDateSelected,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) onDateSelected(picked);
  }

  // Reset form to initial state
  void _resetForm() {
    _titleController.clear();
    _isbnController.clear();
    _descController.clear();
    _priceController.clear();
    _stockController.clear();
    _languageController.clear();
    _formatController.clear();

    setState(() {
      _publisherID = null;
      _isOnSale = false;
      _publicationDate = null;
      _saleStartDate = null;
      _saleEndDate = null;
      _selectedGenreIDs = [];
      _selectedAuthorIDs = [];
      _editingBookId = null;
    });
  }

  // Submit book (add or update)
  Future<void> _submitBook() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate required fields
    if (_publicationDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Publication date is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_publisherID == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Publisher is required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedGenreIDs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one genre'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_selectedAuthorIDs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one author'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Show confirmation dialog for updates
    if (_editingBookId != null) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Confirm Update'),
              content: const Text('Are you sure you want to update this book?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: TextButton.styleFrom(foregroundColor: Colors.black),
                  child: const Text('Update'),
                ),
              ],
            ),
      );

      if (confirmed != true) return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final Map<String, dynamic> bookData = {
        "title": _titleController.text.trim(),
        "isbn": _isbnController.text.trim(),
        "description": _descController.text.trim(),
        "publicationDate": _publicationDate!.toUtc().toIso8601String(),
        "price": double.tryParse(_priceController.text) ?? 0,
        "stock": int.tryParse(_stockController.text) ?? 0,
        "language": _languageController.text.trim(),
        "format": _formatController.text.trim(),
        "publisherID": _publisherID,
        "applicationUserId": _applicationUserId,
        "isOnSale": _isOnSale,
        "genreIDs": _selectedGenreIDs,
        "authorIDs": _selectedAuthorIDs,
      };

      // Add sale dates only if isOnSale is true
      if (_isOnSale) {
        if (_saleStartDate != null) {
          bookData["saleStartDate"] = _saleStartDate!.toUtc().toIso8601String();
        }
        if (_saleEndDate != null) {
          bookData["saleEndDate"] = _saleEndDate!.toUtc().toIso8601String();
        }
      }

      print('Submitting book data: $bookData');

      if (_editingBookId != null) {
        // Update existing book
        await _bookService.updateBook(_editingBookId!, bookData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Book updated successfully'),
              backgroundColor: Colors.black,
            ),
          );
        }
      } else {
        // Add new book
        await _bookService.addBook(bookData);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Book added successfully'),
              backgroundColor: Colors.black,
            ),
          );
        }
      }

      // Reset form and refresh book list
      _resetForm();
      await _fetchBooks();

      // Switch to book list tab
      _tabController.animateTo(1);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red[800],
          ),
        );
      }
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  // Delete a book
  Future<void> _deleteBook(Book book) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Deletion'),
            content: Text('Are you sure you want to delete "${book.title}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.black54),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red[700]),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    try {
      await _bookService.deleteBook(book.bookID);
      await _fetchBooks();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Book deleted successfully'),
            backgroundColor: Colors.black,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Delete failed: $e'),
            backgroundColor: Colors.red[800],
          ),
        );
      }
    }
  }

  // Edit a book
  Future<void> _editBook(Book book) async {
    setState(() {
      _isLoadingBookDetails = true;
    });

    try {
      // Fetch book details including genres and authors
      final bookDetails = await _bookService.getBookById(book.bookID);

      // Populate form with book data
      _titleController.text = book.title;
      _isbnController.text = book.isbn;
      _descController.text = book.description;
      _priceController.text = book.price.toString();
      _stockController.text = book.stock.toString();
      _languageController.text = book.language;
      _formatController.text = book.format;

      setState(() {
        _editingBookId = book.bookID;
        _publisherID = book.publisherID;
        _isOnSale = book.isOnSale;
        _publicationDate = book.publicationDate;
        _saleStartDate = book.saleStartDate;
        _saleEndDate = book.saleEndDate;

        _selectedGenreIDs =
            bookDetails.genres
                .map<int>(
                  (genre) => genre is Genre ? genre.genreID : (genre as int),
                )
                .toList();
        _selectedAuthorIDs =
            bookDetails.authors
                .map<int>(
                  (author) =>
                      author is Author ? author.authorID : (author as int),
                )
                .toList();

        _isLoadingBookDetails = false;
      });

      // Switch to form tab
      _tabController.animateTo(0);

      // Scroll to the top of the form
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_formKey.currentContext != null) {
          Scrollable.ensureVisible(
            _formKey.currentContext!,
            duration: const Duration(milliseconds: 300),
          );
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingBookDetails = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading book details: $e'),
            backgroundColor: Colors.red[800],
          ),
        );
      }
    }
  }

  // Filter books based on search query
  List<Book> get _filteredBooks {
    if (_searchQuery.isEmpty) return _books;

    return _books
        .where(
          (book) =>
              book.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              book.isbn.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AdminAppBar(
        activeRoute: 'books',
        onBooksPressed: () => Navigator.pushNamed(context, '/books'),
        onPublishersPressed: () => Navigator.pushNamed(context, '/publishers'),
        onAnnouncementsPressed:
            () => Navigator.pushNamed(context, '/announcements'),
        onDiscountsPressed: () => Navigator.pushNamed(context, '/discounts'),
        onGenresPressed: () => Navigator.pushNamed(context, '/genres'),
        onAuthorsPressed: () => Navigator.pushNamed(context, '/authors'),
      ),
      body:
          _isLoading
              ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.black),
                    SizedBox(height: 16),
                    Text(
                      'Loading data...',
                      style: TextStyle(color: Colors.black54, fontSize: 16),
                    ),
                  ],
                ),
              )
              : Column(
                children: [
                  // Page header
                  Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Book Management',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Tab bar
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TabBar(
                            controller: _tabController,
                            labelColor: Colors.black,
                            unselectedLabelColor: Colors.black54,
                            indicatorColor: Colors.black,
                            indicatorSize: TabBarIndicatorSize.tab,
                            tabs: [
                              Tab(
                                text:
                                    _editingBookId == null
                                        ? 'Add Book'
                                        : 'Edit Book',
                                icon: Icon(
                                  _editingBookId == null
                                      ? Icons.add_box_outlined
                                      : Icons.edit_outlined,
                                ),
                              ),
                              const Tab(
                                text: 'Book List',
                                icon: Icon(Icons.menu_book_outlined),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tab content
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Add/Edit Book Form
                        _isLoadingBookDetails
                            ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    color: Colors.black,
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    'Loading book details...',
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            )
                            : _buildBookForm(),

                        // Book List
                        _buildBookList(),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }

  Widget _buildBookForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Form container
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _editingBookId == null ? 'Add New Book' : 'Edit Book',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Basic Information
                  const Text(
                    'Basic Information',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: 'Title',
                      hintText: 'Enter book title',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Title is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // ISBN
                  TextFormField(
                    controller: _isbnController,
                    decoration: InputDecoration(
                      labelText: 'ISBN',
                      hintText: 'Enter ISBN',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'ISBN is required';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Description
                  TextFormField(
                    controller: _descController,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      hintText: 'Enter book description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Description is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Publication Details
                  const Text(
                    'Publication Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Publication Date
                  Row(
                    children: [
                      Expanded(
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Publication Date',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: InkWell(
                            onTap:
                                () => _selectDate(
                                  context,
                                  _publicationDate,
                                  (date) =>
                                      setState(() => _publicationDate = date),
                                ),
                            child: Text(
                              _publicationDate == null
                                  ? 'Select date'
                                  : DateFormat.yMMMd().format(
                                    _publicationDate!,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Publisher
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      labelText: 'Publisher',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    value: _publisherID,
                    items:
                        _publishers.map((publisher) {
                          return DropdownMenuItem<int>(
                            value: publisher.publisherID,
                            child: Text(publisher.name),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _publisherID = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a publisher';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Language and Format
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _languageController,
                          decoration: InputDecoration(
                            labelText: 'Language',
                            hintText: 'e.g., English',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Language is required';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _formatController,
                          decoration: InputDecoration(
                            labelText: 'Format',
                            hintText: 'e.g., Paperback',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Format is required';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Inventory & Pricing
                  const Text(
                    'Inventory & Pricing',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Price and Stock
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _priceController,
                          decoration: InputDecoration(
                            labelText: 'Price',
                            hintText: 'Enter price',
                            prefixText: '\$',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Price is required';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            if (double.parse(value) < 0) {
                              return 'Price cannot be negative';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _stockController,
                          decoration: InputDecoration(
                            labelText: 'Stock',
                            hintText: 'Enter stock quantity',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Stock is required';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            if (int.parse(value) < 0) {
                              return 'Stock cannot be negative';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Sale Information
                  SwitchListTile(
                    title: const Text('On Sale'),
                    value: _isOnSale,
                    onChanged: (value) {
                      setState(() {
                        _isOnSale = value;
                      });
                    },
                    activeColor: Colors.black,
                  ),

                  if (_isOnSale) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Sale Start Date',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            child: InkWell(
                              onTap:
                                  () => _selectDate(
                                    context,
                                    _saleStartDate,
                                    (date) =>
                                        setState(() => _saleStartDate = date),
                                  ),
                              child: Text(
                                _saleStartDate == null
                                    ? 'Select date'
                                    : DateFormat.yMMMd().format(
                                      _saleStartDate!,
                                    ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Sale End Date',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            child: InkWell(
                              onTap:
                                  () => _selectDate(
                                    context,
                                    _saleEndDate,
                                    (date) =>
                                        setState(() => _saleEndDate = date),
                                  ),
                              child: Text(
                                _saleEndDate == null
                                    ? 'Select date'
                                    : DateFormat.yMMMd().format(_saleEndDate!),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 24),

                  // Categories
                  const Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Genres
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Genres',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              _genres.map((genre) {
                                final isSelected = _selectedGenreIDs.contains(
                                  genre.genreID,
                                );
                                return FilterChip(
                                  label: Text(genre.name),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedGenreIDs.add(genre.genreID);
                                      } else {
                                        _selectedGenreIDs.remove(genre.genreID);
                                      }
                                    });
                                  },
                                  selectedColor: Colors.black12,
                                  checkmarkColor: Colors.black,
                                );
                              }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Authors
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Authors',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              _authors.map((author) {
                                final isSelected = _selectedAuthorIDs.contains(
                                  author.authorID,
                                );
                                return FilterChip(
                                  label: Text(author.name),
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _selectedAuthorIDs.add(author.authorID);
                                      } else {
                                        _selectedAuthorIDs.remove(
                                          author.authorID,
                                        );
                                      }
                                    });
                                  },
                                  selectedColor: Colors.black12,
                                  checkmarkColor: Colors.black,
                                );
                              }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Form Actions
                  Row(
                    children: [
                      if (_editingBookId != null) ...[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isSubmitting ? null : _resetForm,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: Colors.black12),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isSubmitting ? null : _submitBook,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child:
                              _isSubmitting
                                  ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : Text(
                                    _editingBookId == null
                                        ? 'Add Book'
                                        : 'Update Book',
                                  ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookList() {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Search books...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.black),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        const SizedBox(height: 16),

        // Book list
        Expanded(
          child:
              _isLoadingBooks
                  ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.black),
                        SizedBox(height: 16),
                        Text(
                          'Loading books...',
                          style: TextStyle(color: Colors.black54, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                  : _filteredBooks.isEmpty
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.menu_book_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No books found',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (_searchQuery.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            'Try a different search term',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                  : RefreshIndicator(
                    onRefresh: _fetchBooks,
                    color: Colors.black,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemCount: _filteredBooks.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final book = _filteredBooks[index];
                        return _buildBookCard(book);
                      },
                    ),
                  ),
        ),
      ],
    );
  }

  Widget _buildBookCard(Book book) {
    // Find publisher name
    final publisher = _publishers.firstWhere(
      (p) => p.publisherID == book.publisherID,
      orElse: () => Publisher(publisherID: 0, name: 'Unknown'),
    );

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Book cover placeholder
                Container(
                  width: 80,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.menu_book,
                      size: 40,
                      color: Colors.black38,
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Book details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ISBN: ${book.isbn}',
                        style: TextStyle(color: Colors.grey[700], fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Publisher: ${publisher.name}',
                        style: TextStyle(color: Colors.grey[700], fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Published: ${DateFormat.yMMMd().format((book.publicationDate))}',
                        style: TextStyle(color: Colors.grey[700], fontSize: 14),
                      ),

                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Text(
                              '\$${book.price.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  book.stock > 0
                                      ? Colors.green[50]
                                      : Colors.red[50],
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color:
                                    book.stock > 0
                                        ? Colors.green[300]!
                                        : Colors.red[300]!,
                              ),
                            ),
                            child: Text(
                              book.stock > 0
                                  ? 'In Stock (${book.stock})'
                                  : 'Out of Stock',
                              style: TextStyle(
                                color:
                                    book.stock > 0
                                        ? Colors.green[700]
                                        : Colors.red[700],
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          if (book.isOnSale) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange[50],
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.orange[300]!),
                              ),
                              child: Text(
                                'On Sale',
                                style: TextStyle(
                                  color: Colors.orange[700],
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Actions
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _editBook(book),
                      tooltip: 'Edit',
                      color: Colors.black54,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outlined),
                      onPressed: () => _deleteBook(book),
                      tooltip: 'Delete',
                      color: Colors.black54,
                    ),
                  ],
                ),
              ],
            ),

            // Description preview
            if (book.description.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Description:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                book.description.length > 200
                    ? '${book.description.substring(0, 200)}...'
                    : book.description,
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
