import 'package:book_frontend/widget/admin_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:book_frontend/api/publisher_service.dart';
import 'package:book_frontend/model/publisher.dart';

class PublisherPage extends StatefulWidget {
  const PublisherPage({Key? key}) : super(key: key);

  @override
  _PublisherPageState createState() => _PublisherPageState();
}

class _PublisherPageState extends State<PublisherPage> {
  final PublisherService _publisherService = PublisherService();
  final TextEditingController _publisherController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late Future<List<Publisher>> _publishers;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _publishers = _publisherService.getAllPublishers();
  }

  // Add Publisher with validation
  void _addPublisher() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);

      try {
        final name = _publisherController.text.trim();
        await _publisherService.addPublisher(name);

        setState(() {
          _publishers = _publisherService.getAllPublishers();
          _isSubmitting = false;
        });

        _publisherController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Publisher added successfully'),
            backgroundColor: Colors.black,
            duration: Duration(seconds: 2),
          ),
        );
      } catch (e) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red[800],
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  // Delete Publisher with confirmation
  void _deletePublisher(Publisher publisher) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Deletion'),
            content: Text(
              'Are you sure you want to delete "${publisher.name}"?',
            ),
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

    if (confirmed == true) {
      try {
        await _publisherService.deletePublisher(publisher.publisherID);
        setState(() {
          _publishers = _publisherService.getAllPublishers();
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Publisher deleted'),
              backgroundColor: Colors.black,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red[800],
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AdminAppBar(
        activeRoute: 'publishers',
        onBooksPressed: () => Navigator.pushNamed(context, '/books'),
        onPublishersPressed: () => Navigator.pushNamed(context, '/publishers'),
        onAnnouncementsPressed:
            () => Navigator.pushNamed(context, '/announcements'),
        onDiscountsPressed: () => Navigator.pushNamed(context, '/discounts'),
        onGenresPressed: () => Navigator.pushNamed(context, '/genres'),
        onAuthorsPressed: () => Navigator.pushNamed(context, '/authors'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Title
            const Text(
              'Publishers',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 24),

            // Add Publisher Form
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
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add New Publisher',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _publisherController,
                      decoration: InputDecoration(
                        labelText: 'Publisher Name',
                        hintText: 'Enter publisher name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(color: Colors.black12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Publisher name is required';
                        }
                        if (value.trim().length < 2) {
                          return 'Name must be at least 2 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _addPublisher,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          disabledBackgroundColor: Colors.black38,
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
                                : const Text(
                                  'Add Publisher',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Publishers List Title
            const Text(
              'Publisher List',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),

            // List of Publishers
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black12),
                ),
                child: FutureBuilder<List<Publisher>>(
                  future: _publishers,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.black),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.black38,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error loading publishers',
                              style: TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text(
                          'No publishers found',
                          style: TextStyle(color: Colors.black54, fontSize: 16),
                        ),
                      );
                    }

                    final publishers = snapshot.data!;

                    return ListView.separated(
                      itemCount: publishers.length,
                      separatorBuilder:
                          (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final publisher = publishers[index];

                        return ListTile(
                          title: Text(
                            publisher.name,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.black54,
                            ),
                            onPressed: () => _deletePublisher(publisher),
                            tooltip: 'Delete publisher',
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
