import 'package:flutter/material.dart';

class CategoryPage extends StatelessWidget {
  final List<Map<String, String>> products = [
    {
      'name': 'Ocayle',
      'price': '\$119.00',
      'image': 'assets/images/image01.jpg', // Updated image path
    },
    {
      'name': 'Xami',
      'price': '\$129.00',
      'image': 'assets/images/image01.jpg', // Updated image path
    },
    {
      'name': 'Lana',
      'price': '\$129.00',
      'image': 'assets/images/image01.jpg', // Updated image path
    },
    {
      'name': 'Ulani',
      'price': '\$119.00',
      'image': 'assets/images/image01.jpg', // Updated image path
    },
    {
      'name': 'Black Shoes',
      'price': '\$119.00',
      'image': 'assets/images/image01.jpg', // Updated image path
    },
    {
      'name': 'Beige Shoes',
      'price': '\$129.00',
      'image': 'assets/images/image01.jpg', // Updated image path
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WOVEN STYLES'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              // Navigate to the cart page
              Navigator.pushNamed(context, '/cart');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          itemCount: products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 0.75, // Adjust to your preferred aspect ratio
          ),
          itemBuilder: (context, index) {
            final product = products[index];
            return GestureDetector(
              onTap: () {
                // Navigate to the product page when the card is clicked
                Navigator.pushNamed(context, '/product_page', arguments: product);
              },
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: Image.asset(
                        product['image']!,
                        height: 160,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product['name']!,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product['price']!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Use a fixed height for the button container
                          Container(
                            width: double.infinity,
                            height: 50, // Set fixed height for the button
                            margin: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.pink, Colors.orange],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextButton(
                              onPressed: () {
                                // Add to cart logic here
                                Navigator.pushNamed(context, '/cart_page');
                              },
                              child: const Text(
                                'Add to Cart',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}