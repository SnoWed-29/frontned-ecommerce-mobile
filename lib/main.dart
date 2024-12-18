import 'package:flutter/material.dart';
import 'package:frontned/pages/cart_page.dart';
import 'package:frontned/pages/category_page.dart';
import 'package:frontned/pages/product_page.dart';
import 'package:frontned/pages/shop_page.dart';
import 'package:frontned/pages/add_product_page.dart'; // Import AddProductPage
import 'package:frontned/pages/user_products_page.dart';
import 'package:frontned/themes/light_mode.dart';
import 'package:frontned/pages/intro_page.dart';
import 'package:frontned/pages/login_page.dart';
import 'package:frontned/pages/register_page.dart';
import 'package:frontned/services/auth_service.dart'; // Import the AuthService
import 'components/drawer.dart'; // Import the Drawer

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
      initialRoute: '/shop_page', // Initial route
      routes: {
        '/intro_page': (context) => const IntroPage(),
        '/shop_page': (context) => const ShopPage(),
        '/category_page': (context) => CategoryPage(),
        '/login_page': (context) => const LoginPage(),
        '/user_product_page': (context) =>  UserProductsPage(),
        '/register_page': (context) => const RegisterPage(),
        '/add_product_page': (context) => AddProductPage(), // Add the AddProductPage route
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
      home: const SplashScreen(), // Use a SplashScreen to handle redirection
    );
  }
}
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthService().isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Proceed to the appropriate page based on login status
        if (snapshot.hasData && snapshot.data == true) {
          // User is logged in, move to the main page
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainPage()),
            );
          });
        } else {
          // User is not logged in, move to the login page
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          });
        }

        return const SizedBox.shrink(); // Empty widget while waiting
      },
    );
  }
}
class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: ShopPage(), // Ensure ShopPage stays in the stack
    );
  }
}
