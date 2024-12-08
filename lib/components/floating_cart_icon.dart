import 'package:flutter/material.dart';

class FloatingCartIcon extends StatelessWidget {
  final VoidCallback onPressed;

  const FloatingCartIcon({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20, // Adjust the position from the bottom
      right: 20,  // Adjust the position from the right
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.shopping_cart),
      ),
    );
  }
}