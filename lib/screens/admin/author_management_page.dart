import 'package:book_frontend/api/author_service.dart';
import 'package:book_frontend/model/author.dart';
import 'package:book_frontend/widget/admin_app_bar.dart';
import 'package:flutter/material.dart';

class AuthorManagementPage extends StatefulWidget {
  const AuthorManagementPage({Key? key}) : super(key: key);

  @override
  State<AuthorManagementPage> createState() => _AuthorManagementPageState();
}

class _AuthorManagementPageState extends State<AuthorManagementPage> {
  final _authorService = AuthorService();
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  int? _editingAuthorId;
  List<Author> _authors = [];
  bool _isLoading = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchAuthors();
  }

  Future<void> _fetchAuthors() async {
    setState(() => _isLoading = true);
    try {
      final authors = await _authorService.getAllAuthors();
      setState(() {
        _authors = authors;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading authors: $e'),
            backgroundColor: Colors.red[800],
          ),
        );
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      final name = _nameController.text.trim();

      if (_editingAuthorId == null) {
        await _authorService.createAuthor(name);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Author added successfully'),
              backgroundColor: Colors.black,
            ),
          );
        }
      } else {
        await _authorService.updateAuthor(_editingAuthorId!, name);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Author updated successfully'),
              backgroundColor: Colors.black,
            ),
          );
        }
      }

      _nameController.clear();
      _editingAuthorId = null;
      await _fetchAuthors();
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
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _deleteAuthor(Author author) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirm Deletion'),
            content: Text('Are you sure you want to delete "${author.name}"?'),
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
      await _authorService.deleteAuthor(author.authorID);
      await _fetchAuthors();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Author deleted successfully'),
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

  void _editAuthor(Author author) {
    setState(() {
      _nameController.text = author.name;
      _editingAuthorId = author.authorID;
    });

    // Scroll to the top and focus the text field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }

  void _cancelEdit() {
    setState(() {
      _nameController.clear();
      _editingAuthorId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AdminAppBar(
        activeRoute: 'authors',
        onBooksPressed: () => Navigator.pushNamed(context, '/books'),
        onPublishersPressed: () => Navigator.pushNamed(context, '/publishers'),
        onAnnouncementsPressed:
            () => Navigator.pushNamed(context, '/announcements'),
        onDiscountsPressed: () => Navigator.pushNamed(context, '/discounts'),
        onGenresPressed: () => Navigator.pushNamed(context, '/genres'),
        onAuthorsPressed: () => Navigator.pushNamed(context, '/authors'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Page Title
            const Text(
              'Author Management',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 24),

            // Add/Edit Author Form
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
                    Text(
                      _editingAuthorId == null
                          ? 'Add New Author'
                          : 'Edit Author',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Author Name',
                        hintText: 'Enter author name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(color: Colors.black12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(4),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Author name is required';
                        }
                        if (value.trim().length < 2) {
                          return 'Name must be at least 2 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        if (_editingAuthorId != null) ...[
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isSubmitting ? null : _cancelEdit,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.black,
                                side: const BorderSide(color: Colors.black12),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                        ],
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submit,
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
                                    : Text(
                                      _editingAuthorId == null
                                          ? 'Add Author'
                                          : 'Update Author',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
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
            const SizedBox(height: 24),

            // Authors List Title
            const Text(
              'Author List',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),

            // Authors List
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black12),
                ),
                child:
                    _isLoading
                        ? const Center(
                          child: CircularProgressIndicator(color: Colors.black),
                        )
                        : _authors.isEmpty
                        ? const Center(
                          child: Text(
                            'No authors found',
                            style: TextStyle(
                              color: Colors.black54,
                              fontSize: 16,
                            ),
                          ),
                        )
                        : ListView.separated(
                          itemCount: _authors.length,
                          separatorBuilder:
                              (context, index) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final author = _authors[index];
                            final isEditing =
                                _editingAuthorId == author.authorID;

                            return ListTile(
                              title: Text(
                                author.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  color:
                                      isEditing ? Colors.black : Colors.black87,
                                  fontWeight:
                                      isEditing
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.edit_outlined,
                                      color:
                                          isEditing
                                              ? Colors.black
                                              : Colors.black54,
                                    ),
                                    onPressed: () => _editAuthor(author),
                                    tooltip: 'Edit author',
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.black54,
                                    ),
                                    onPressed: () => _deleteAuthor(author),
                                    tooltip: 'Delete author',
                                  ),
                                ],
                              ),
                              tileColor: isEditing ? Colors.grey[50] : null,
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
