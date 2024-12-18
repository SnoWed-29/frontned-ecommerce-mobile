import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../pages/product_page.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final TextEditingController _searchController = TextEditingController();
  final ProductService _productService = ProductService();
  List<Product> _searchResults = [];
  bool _isSearching = false;

  // Search products based on query
  void _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults.clear();
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      List<Product> results = await _productService.searchProducts(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      print('Error searching products: $e');
      setState(() {
        _isSearching = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error searching products: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          // Drawer Header with Search Bar
          Container(
            color: Colors.teal,
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _performSearch,
              decoration: InputDecoration(
                hintText: "Search...",
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                hintStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.teal[700],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          // Search Results
          if (_isSearching)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          if (!_isSearching && _searchResults.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  // Server URL
                  final product = _searchResults[index];
                  return ListTile(
                    leading: product.images.isNotEmpty
                        ? Image.network(product.images[0].path,
                            width: 50, height: 50, fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            } else {
                              return const CircularProgressIndicator();
                            }
                          }, errorBuilder: (context, error, stackTrace) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Icon(Icons.broken_image),
                                const Text('Error loading image'),
                                Text(error.toString(),
                                    style: TextStyle(color: Colors.red)),
                              ],
                            );
                          })
                        : const Icon(Icons.image, size: 50),
                    title: Text(product.name),
                    subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProductPage(productId: product.id),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          if (!_isSearching &&
              _searchResults.isEmpty &&
              _searchController.text.isNotEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'No results found',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          // Drawer Items
          Expanded(
            child: ListView(
              children: [
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.home),
                  title: const Text('Home'),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/shop_page');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.category),
                  title: const Text('Categories'),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/category_page');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.category),
                  title: const Text('My Products'),
                  onTap: () {
                    Navigator.pushReplacementNamed(
                        context, '/user_product_page');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text('Add Product'),
                  onTap: () {
                    Navigator.pushReplacementNamed(
                        context, '/add_product_page');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.login),
                  title: const Text('Logout'),
                  onTap: () {
                    Navigator.pushReplacementNamed(context, '/login_page');
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
