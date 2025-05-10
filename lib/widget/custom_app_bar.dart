import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isLoggedIn;
  final VoidCallback? onHomePressed;
  final VoidCallback? onCatalogPressed;
  final VoidCallback? onBookmarkPressed;
  final VoidCallback? onCartPressed;
  final VoidCallback? onLoginPressed;
  final VoidCallback? onRegisterPressed;
  final String? activeRoute;

  const CustomAppBar({
    super.key,
    required this.isLoggedIn,
    this.onHomePressed,
    this.onCatalogPressed,
    this.onBookmarkPressed,
    this.onCartPressed,
    this.onLoginPressed,
    this.onRegisterPressed,
    this.activeRoute,
  });

  @override
  Widget build(BuildContext context) {
    // Default AppBar layout
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
            'BookHaven',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w700,
              fontSize: 18,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(width: 40),
          _buildNavButton('home', 'Home', onHomePressed),
          _buildNavButton('catalog', 'Catalog', onCatalogPressed),
          _buildNavButton('bookmark', 'Bookmark', onBookmarkPressed),
          const Spacer(),
          if (isLoggedIn)
            _buildIconButton(Icons.shopping_cart_outlined, onCartPressed)
          else
            Row(
              children: [
                _buildTextButton('Login', false, onLoginPressed),
                const SizedBox(width: 12),
                _buildTextButton('Register', true, onRegisterPressed),
              ],
            ),
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

  Widget _buildIconButton(IconData icon, VoidCallback? onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.black87, size: 22),
      ),
    );
  }

  Widget _buildTextButton(
    String label,
    bool isPrimary,
    VoidCallback? onPressed,
  ) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: isPrimary ? Colors.white : Colors.black87,
        backgroundColor: isPrimary ? Colors.black : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side:
              isPrimary
                  ? BorderSide.none
                  : BorderSide(color: Colors.grey[300]!),
        ),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.3,
        ),
      ),
      child: Text(label),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
