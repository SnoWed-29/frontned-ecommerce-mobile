import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../pages/product_page.dart';
import './cart_page.dart';
import '../services/auth_service.dart'; // Import the AuthService
import '../components/drawer.dart'; // Import the custom AppDrawer
import 'package:cached_network_image/cached_network_image.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  _ShopPageState createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  bool _isLoading = true;
  List<Product> _products = [];
  List<String> _categories = []; // Fetch categories dynamically
  int _selectedCategoryIndex = 0; // To keep track of the selected category

  final ProductService productService = ProductService();
  final AuthService authService = AuthService(); // Instance of AuthService

  int? _userId; // To store the logged-in user's ID

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Fetch user data on initialization
    _fetchProducts(); // Load all products initially
    _fetchCategories();
  }

  // Fetch the logged-in user's data
  void _fetchUserData() async {
    try {
      int? userId =
          await authService.getUserId(); // Assume `getUserId()` exists
      setState(() {
        _userId = userId;
      });
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  // Fetch categories from the provided API endpoint
  void _fetchCategories() async {
    try {
      List<String> categories = await productService.fetchCategories();
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      print('Error fetching categories: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching categories: $e')),
      );
    }
  }

  void _fetchProducts() async {
    setState(() => _isLoading = true);
    try {
      List<Product> products = await productService.fetchProducts();
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error fetching products: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching products: $e')),
      );
    }
  }

  void _fetchProductsByCategory(int categoryId) async {
    setState(() => _isLoading = true);
    try {
      List<Product> products =
          await productService.fetchProductsByCategory(categoryId);
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('Error fetching products by category: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching products: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.teal,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        title: const Text(
          "Discover",
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {
              if (_userId != null) {
                Navigator.pushNamed(
                  context,
                  '/cart_page',
                  arguments: _userId, // Pass the actual user ID
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User not logged in!')),
                );
              }
            },
          ),
        ],
      ),
      drawer: const AppDrawer(), // Replace the current drawer with AppDrawer
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                const SizedBox(height: 16),

                // Horizontal Category Scroller
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length + 1, // +1 for "All" button
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedCategoryIndex = index;
                          });
                          if (index == 0) {
                            // Fetch all products when "All" is selected
                            _fetchProducts();
                          } else {
                            // Fetch products by category
                            int categoryId =
                                index; // Adjust this if categories have IDs
                            _fetchProductsByCategory(categoryId);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: _selectedCategoryIndex == index
                                ? Colors.teal
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              index == 0 ? "All" : _categories[index - 1],
                              style: TextStyle(
                                color: _selectedCategoryIndex == index
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Product Grid
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 3 / 4,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      final String baseUrl =
                          'http://127.0.0.1:8000/'; // Replace with your API's base URL
                      final imageUrl = product.images[0].path;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductPage(
                                productId: product.id,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                blurRadius: 6,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12)),
                                  child: CachedNetworkImage(
                                    imageUrl: imageUrl,
                                    placeholder: (context, url) =>
                                        CircularProgressIndicator(),
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.error),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      product.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.teal,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '\$${product.price}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w700,
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
                )
              ],
            ),
    );
  }
}
