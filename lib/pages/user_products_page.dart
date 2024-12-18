import 'package:flutter/material.dart';
import '../services/product_service.dart';
import '../models/product.dart'; // Import the Product model
import 'product_page.dart'; // Import the ProductPage

class UserProductsPage extends StatefulWidget {
  @override
  _UserProductsPageState createState() => _UserProductsPageState();
}

class _UserProductsPageState extends State<UserProductsPage> {
  late Future<List<Product>> userProducts;

  @override
  void initState() {
    super.initState();
    userProducts = ProductService().fetchUserProducts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Products'),
      ),
      body: FutureBuilder<List<Product>>(
        future: userProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No products found.'));
          }

          final productList = snapshot.data!;

          return ListView.builder(
            itemCount: productList.length,
            itemBuilder: (context, index) {
              final product = productList[index];

              return Card(
                child: ListTile(
                  leading: GestureDetector(
                    onTap: () {
                      // Navigate to the product page when the image is tapped
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProductPage(productId: product.id),
                        ),
                      );
                    },
                    child: Image.network(
                      product.images.isNotEmpty
                          ? product.images[0].path
                          : 'https://via.placeholder.com/150',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(product.name),
                  subtitle: Text('\$${product.price}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const  Icon(Icons.edit),
                        onPressed: () {
                          // Edit action (you can implement this)
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirmDelete = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Product'),
                              content: const Text(
                                  'Are you sure you want to delete this product?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete',
                                      style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );

                          if (confirmDelete == true) {
                            try {
                              await ProductService().deleteProduct(product.id);

                              // Refresh the product list after deletion
                              setState(() {
                                userProducts =
                                    ProductService().fetchUserProducts();
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                               const SnackBar(
                                    content:
                                        Text('Product deleted successfully')),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('Failed to delete product: $e')),
                              );
                            }
                          }
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
    );
  }
}
