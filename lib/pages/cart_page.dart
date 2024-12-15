import 'package:flutter/material.dart';
import '../services/product_service.dart';

class CartPage extends StatefulWidget {
  final int userId;

  const CartPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final ProductService _productService = ProductService();
  late Future<List<dynamic>> _cartItems;
  double totalPrice = 0.0;

  @override
  void initState() {
    super.initState();
    _cartItems = _productService.fetchCartItems(widget.userId);
  }

  // Method to calculate the total price
  void _calculateTotal(List<dynamic> cartItems) {
    double total = 0.0;

    for (var item in cartItems) {
      // Parse the price as double
      double price = double.tryParse(item['price'].toString()) ?? 0.0;
      int quantity = item['pivot']['quantity'] ?? 0;

      // Debugging: Print values to ensure they are correct
      print('Price: $price, Quantity: $quantity');

      total += price * quantity;
    }

    // Update the totalPrice state
    setState(() {
      totalPrice = total;
    });

    // Debugging: Print total price
    print('Total Price Calculated: $totalPrice');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cart'),
        backgroundColor: Colors.teal,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _cartItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Your cart is empty'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Your cart is empty.'));
          }

          final cartItems = snapshot.data!;
          // Calculate total when cart items are fetched
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _calculateTotal(cartItems);
          });

          return ListView.builder(
            itemCount: cartItems.length,
            itemBuilder: (context, index) {
              final item = cartItems[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      // Picture
                      Image.network(
                        item['images'][0]['path'],
                        height: 60,
                        width: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.broken_image, size: 60);
                        },
                      ),
                      const SizedBox(width: 10),

                      // Product Name, Price, and Quantity
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Product Name
                            Text(
                              item['name'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 5),

                            // Price
                            Text(
                              '\$${item['price']}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.teal,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Quantity
                      Text(
                        'x${item['pivot']['quantity']}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      // Spacer between Quantity and Delete Button
                      const SizedBox(width: 20),

                      // Delete Button
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () {
                          // Handle item removal logic
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      // Bottom Bar with Total Price and Confirm Order Button
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(15.0),
        color: Colors.teal[50],
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Total Price
            Text(
              'Total Price: \$${totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            // Confirm Order Button
            ElevatedButton(
              onPressed: () {
                // Handle order confirmation logic here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Order Confirmed!')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,  // Use backgroundColor instead of primary
              ),
              child: const Text(
                'Confirm Order',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}