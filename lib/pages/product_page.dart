import 'package:flutter/material.dart';
import '../services/product_service.dart';
import '../services/auth_service.dart'; // Import the AuthService

class ProductPage extends StatelessWidget {
  final int productId;

  const ProductPage({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    final productService = ProductService();
    final authService = AuthService(); // Create an instance of AuthService

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Transparent background
        elevation: 0, // Remove shadow
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black), // Back icon
          onPressed: () {
            Navigator.of(context).pop(); // Go back when pressed
          },
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: productService.fetchProductDetails(productId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final product = snapshot.data!;
            final images = product['images'] as List<dynamic>; // Extract images array

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display product images
                  Container(
                    height: 250,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        final imageUrl = images[index]['path'] as String;
                        return GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => FullScreenImage(imageUrl: imageUrl),
                              ),
                            );
                          },
                          child: Image.network(
                            imageUrl,
                            width: MediaQuery.of(context).size.width, // Full width
                            height: 250,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 100),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(product['name'], style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Price: \$${product['price']}', style: const TextStyle(fontSize: 18, color: Color(0xFF4CAF50))), // Green price text
                        const SizedBox(height: 16),
                        Text('Description:', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(product['description']),
                      ],
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No product details available.'));
          }
        },
      ),
      bottomSheet: FutureBuilder<Map<String, dynamic>>(
        future: productService.fetchProductDetails(productId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(); // Empty space while waiting for data
          } else if (snapshot.hasError) {
            return const SizedBox(); // Empty space in case of error
          } else if (snapshot.hasData) {
            final product = snapshot.data!;
            return Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Price at the bottom
                  Text(
                    '\$${product['price']}',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF4CAF50)),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      // Retrieve the actual logged-in user ID from AuthService
                      final userId = await authService.getUserId();

                      if (userId != null) {
                        // Example: adding 1 product to the cart
                        int quantity = 1; 
                        await productService.addToCart(userId, productId, quantity);

                        // Show a confirmation message
                        final snackBar = SnackBar(content: Text('Product added to cart!'));
                        ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      } else {
                        // Handle the case where user ID is not found or user is not logged in
                        print('User not logged in or session expired.');
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text('Add to Cart', style: TextStyle(fontSize: 16)),
                  ),
                ],
              ),
            );
          } else {
            return const SizedBox(); // Empty space if no data is available
          }
        },
      ),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white), // Close icon
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: Image.network(
          imageUrl,
          fit: BoxFit.contain,
          width: MediaQuery.of(context).size.width, // Full width
          height: MediaQuery.of(context).size.height, // Full height
        ),
      ),
    );
  }
}