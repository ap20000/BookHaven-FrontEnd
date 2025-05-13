import 'package:book_frontend/api/auth_service.dart';
import 'package:book_frontend/screens/add_review_page.dart';
import 'package:flutter/material.dart';
import 'package:book_frontend/model/book.dart';
import 'package:book_frontend/api/book_service.dart';
import 'package:book_frontend/api/cart_service.dart';

class BookDetailPage extends StatefulWidget {
  final int bookId;

  const BookDetailPage({Key? key, required this.bookId}) : super(key: key);

  @override
  State<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  final BookService _bookService = BookService();
  late Future<Book> _bookFuture;
  bool _isBookmarked = false;

  // Dummy review data
  final List<Map<String, dynamic>> _reviews = [
    {
      'name': 'Alex Johnson',
      'date': '2023-10-15',
      'rating': 5,
      'comment':
          'This book exceeded my expectations. The narrative is compelling and the characters are well-developed. I couldn\'t put it down!',
    },
    {
      'name': 'Sarah Miller',
      'date': '2023-09-28',
      'rating': 4,
      'comment':
          'A great read overall. The plot was engaging though I found some parts to be a bit slow. Would recommend to friends who enjoy this genre.',
    },
    {
      'name': 'Michael Chen',
      'date': '2023-09-05',
      'rating': 5,
      'comment':
          'Absolutely brilliant. The author has a unique writing style that draws you in from the first page. One of my favorite books this year.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _bookFuture = _bookService.getBookById(widget.bookId);
  }

  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
    // In a real app, you would save this state to a database or local storage
  }

  Future<void> _addToCart(int bookId) async {
    try {
      final authService = AuthService();
      final userId = await authService.getUserId();

      if (userId == null) {
        throw Exception('User ID not found. Please log in again.');
      }

      final cartService = CartService();
      await cartService.addToCart(userId, bookId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Book added to cart'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _navigateToAddReview() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddReviewPage(bookId: widget.bookId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: FutureBuilder<Book>(
        future: _bookFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.black,
                strokeWidth: 2,
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.black54),
                  const SizedBox(height: 16),
                  Text(
                    'Unable to load book details',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData) {
            return const Center(
              child: Text(
                'Book not found',
                style: TextStyle(color: Colors.black87, fontSize: 16),
              ),
            );
          }

          final book = snapshot.data!;

          // Format the publication date
          final formattedDate =
              book.publicationDate.toString().split('T').first;

          // Check if stock is available
          final bool isInStock = book.stock > 0;

          return LayoutBuilder(
            builder: (context, constraints) {
              // Use a different layout for different screen sizes
              final bool isWideScreen = constraints.maxWidth > 900;

              if (isWideScreen) {
                // Two-column layout for wide screens
                return _buildWideLayout(book, formattedDate, isInStock);
              } else {
                // Single column layout for narrower screens
                return _buildNarrowLayout(book, formattedDate, isInStock);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildWideLayout(Book book, String formattedDate, bool isInStock) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left column - Book cover and purchase options
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Row(
                          children: [
                            Icon(
                              Icons.arrow_back,
                              size: 16,
                              color: Colors.black54,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Back to catalog',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Book cover
                    Container(
                      height: 400,
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
                      child: Center(
                        child: Icon(
                          Icons.menu_book,
                          size: 80,
                          color: Colors.black26,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Price and purchase section
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '\$${book.price.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              // Add to Cart button
                              Expanded(
                                child: ElevatedButton(
                                  onPressed:
                                      isInStock
                                          ? () => _addToCart(book.bookID)
                                          : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        isInStock
                                            ? Colors.black
                                            : Colors.black12,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  child: Text(
                                    isInStock ? 'Add to Cart' : 'Out of Stock',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),

                              // Bookmark button
                              const SizedBox(width: 12),
                              MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: GestureDetector(
                                  onTap: _toggleBookmark,
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.black12),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Icon(
                                      _isBookmarked
                                          ? Icons.bookmark
                                          : Icons.bookmark_border,
                                      color:
                                          _isBookmarked
                                              ? Colors.black
                                              : Colors.black54,
                                      size: 24,
                                    ),
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

              const SizedBox(width: 40),

              // Right column - Book details
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Book metadata
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Column(
                        children: [
                          _buildInfoRow('ISBN', book.isbn),
                          _buildInfoRow('Language', book.language),
                          _buildInfoRow('Format', book.format),
                          _buildInfoRow('Publication Date', formattedDate),
                          _buildInfoRow(
                            'Available Stock',
                            '${book.stock} copies',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Description section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.black12),
                          ),
                          child: Text(
                            book.description,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              height: 1.6,
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

          // Reviews section - Full width below the two columns
          const SizedBox(height: 48),
          _buildReviewsSection(),
        ],
      ),
    );
  }

  Widget _buildNarrowLayout(Book book, String formattedDate, bool isInStock) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Row(
                children: [
                  Icon(Icons.arrow_back, size: 16, color: Colors.black54),
                  const SizedBox(width: 8),
                  Text(
                    'Back to catalog',
                    style: TextStyle(color: Colors.black54, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Book title
          Text(
            book.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 24),

          // Book cover
          Center(
            child: Container(
              height: 300,
              width: 220,
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
              child: Center(
                child: Icon(Icons.menu_book, size: 60, color: Colors.black26),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Price and add to cart
          Center(
            child: Container(
              width: 220,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black12),
              ),
              child: Column(
                children: [
                  Text(
                    '\$${book.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      // Add to Cart button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isInStock ? () {} : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isInStock ? Colors.black : Colors.black12,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          child: Text(
                            isInStock ? 'Add to Cart' : 'Out of Stock',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      // Bookmark button
                      const SizedBox(width: 8),
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: _toggleBookmark,
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Icon(
                              _isBookmarked
                                  ? Icons.bookmark
                                  : Icons.bookmark_border,
                              color:
                                  _isBookmarked ? Colors.black : Colors.black54,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Book metadata
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black12),
            ),
            child: Column(
              children: [
                _buildInfoRow('ISBN', book.isbn),
                _buildInfoRow('Language', book.language),
                _buildInfoRow('Format', book.format),
                _buildInfoRow('Publication Date', formattedDate),
                _buildInfoRow('Available Stock', '${book.stock} copies'),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Description section
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.black12),
            ),
            child: Text(
              book.description,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.6,
              ),
            ),
          ),

          // Reviews section
          const SizedBox(height: 32),
          _buildReviewsSection(),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Customer Reviews',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: _navigateToAddReview,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.black),
                  ),
                  child: const Text(
                    'Write a Review',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Overall rating
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.black12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    '4.7',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < 4 ? Icons.star : Icons.star_half,
                            color: Colors.black,
                            size: 20,
                          );
                        }),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Based on ${_reviews.length} reviews',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Individual reviews
        ..._reviews.map((review) => _buildReviewItem(review)).toList(),

        // Add review button (mobile-friendly placement)
        const SizedBox(height: 32),
        Center(
          child: ElevatedButton(
            onPressed: _navigateToAddReview,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: const Text(
              'Write a Review',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewItem(Map<String, dynamic> review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                review['name'],
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                review['date'],
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < review['rating'] ? Icons.star : Icons.star_border,
                color: Colors.black,
                size: 16,
              );
            }),
          ),
          const SizedBox(height: 12),
          Text(
            review['comment'],
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
