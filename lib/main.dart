import 'package:flutter/material.dart';
import 'package:frontned/pages/cart_page.dart';
import 'package:frontned/pages/category_page.dart';
import 'package:frontned/pages/product_page.dart';
import 'package:frontned/pages/shop_page.dart';
import 'package:frontned/pages/add_product_page.dart'; // Import AddProductPage
import 'package:frontned/themes/light_mode.dart';
import 'package:frontned/pages/intro_page.dart';
import 'package:frontned/pages/login_page.dart';
import 'package:frontned/pages/register_page.dart';
import 'package:frontned/services/auth_service.dart'; // Import the AuthService

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightMode,
      initialRoute: '/', // Initial route
      routes: {
        '/intro_page': (context) => const IntroPage(),
        '/shop_page': (context) => const ShopPage(),
        '/category_page': (context) => CategoryPage(),
        '/login_page': (context) => const LoginPage(),
        '/register_page': (context) => const RegisterPage(),
        '/add_product_page': (context) =>
            AddProductPage(), // Add the AddProductPage route
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/product_page') {
          final productId = settings.arguments as int?;
          return MaterialPageRoute(
            builder: (context) {
              return ProductPage(productId: productId ?? 0);
            },
          );
        } else if (settings.name == '/cart_page') {
          final userId = settings.arguments as int?;
          return MaterialPageRoute(
            builder: (context) {
              return CartPage(userId: userId ?? 0);
            },
          );
        }
        return null; // Default return for unknown routes
      },
      home: FutureBuilder<bool>(
        future: AuthService().isLoggedIn(), // Check if user is logged in
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData && snapshot.data == true) {
            // User is logged in, navigate to the main screen (bottom navigation)
            return const MainNavigation();
          } else {
            // User is not logged in, navigate to the login page
            return const LoginPage();
          }
        },
      ),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  _MainNavigationState createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const ShopPage(), // Shop
    AddProductPage(), // Add Product Page
    const CartPage(userId: 0), // Cart
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.teal, // Set active color to teal
        unselectedItemColor: Colors.black, // Set inactive color to black
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Shop', // ShopPage
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Add Product', // AddProductPage
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart', // CartPage
          ),
        ],
      ),
    );
  }
}