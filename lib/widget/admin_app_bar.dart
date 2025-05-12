import 'package:flutter/material.dart';

class AdminAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onBooksPressed;
  final VoidCallback? onPublishersPressed;
  final VoidCallback? onAnnouncementsPressed;
  final VoidCallback? onDiscountsPressed;
  final VoidCallback? onGenresPressed;
  final VoidCallback? onAuthorsPressed;
  final String? activeRoute;

  const AdminAppBar({
    super.key,
    this.onBooksPressed,
    this.onPublishersPressed,
    this.onAnnouncementsPressed,
    this.onDiscountsPressed,
    this.onGenresPressed,
    this.onAuthorsPressed,
    this.activeRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        children: [
          const Text(
            'Admin Panel',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: 18,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(width: 40),
          _buildNavButton('books', 'Books', onBooksPressed),
          _buildNavButton('publishers', 'Publishers', onPublishersPressed),
          _buildNavButton(
            'announcements',
            'Announcements',
            onAnnouncementsPressed,
          ),
          _buildNavButton('discounts', 'Discounts', onDiscountsPressed),
          _buildNavButton('genres', 'Genres', onGenresPressed),
          _buildNavButton('authors', 'Authors', onAuthorsPressed),
        ],
      ),
    );
  }

  Widget _buildNavButton(String route, String label, VoidCallback? onPressed) {
    final bool isActive = activeRoute == route;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.black : Colors.grey[400],
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                fontSize: 14,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              height: 2,
              width: 24,
              color: isActive ? Colors.black : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
