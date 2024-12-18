import 'package:flutter/material.dart';
import '../services/product_service.dart';
import './order_confirmation_page.dart';

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

  // Calculate the total price of cart items
  void _calculateTotal(List<dynamic> cartItems) {
    double total = 0.0;

    for (var item in cartItems) {
      double price = double.tryParse(item['price'].toString()) ?? 0.0;
      int quantity = item['pivot']['quantity'] ?? 0;
      total += price * quantity;
    }

    setState(() {
      totalPrice = total;
    });
  }

  // Method to delete a product from the cart
  Future<void> _deleteProduct(int cartId, int productId) async {
    try {
      final response =
          await _productService.deleteProductFromCart(cartId, productId);
      if (response['message'] != null) {
        setState(() {
          _cartItems = _productService
              .fetchCartItems(widget.userId); // Refresh cart items
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'])),
        );
      } else {
        throw Exception(response['error'] ?? 'Error deleting product');
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete product: $error')),
      );
    }
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
            return const Center(child: Text('Error loading cart items.'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Your cart is empty.'));
          }

          final cartItems = snapshot.data!;
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
                            Text(
                              item['name'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
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
                      const SizedBox(width: 20),

                      // Delete Button
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () {
                          _deleteProduct(item['pivot']['cart_id'], item['id']);
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
            Text(
              'Total Price: \$${totalPrice.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderConfirmationPage(
                      userId: widget.userId,
                      totalPrice: totalPrice,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
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
