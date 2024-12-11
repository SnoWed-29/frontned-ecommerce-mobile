import 'package:flutter/material.dart';
import 'package:frontned/pages/cart_page.dart';
import 'package:frontned/pages/category_page.dart';
import 'package:frontned/pages/product_page.dart';
import 'package:frontned/pages/shop_page.dart';
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
      home: FutureBuilder<bool>(
        future: AuthService().isLoggedIn(), // Check if user is logged in
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData && snapshot.data == true) {
            // User is logged in, navigate to the main screen
            return const ShopPage();
          } else {
            // User is not logged in, navigate to the login page
            return const LoginPage();
          }
        },
      ),
      routes: {
        '/intro_page': (context) => const IntroPage(),
        '/shop_page': (context) => const ShopPage(),
        '/cart_page': (context) => const CartPage(),
        '/category_page': (context) =>  CategoryPage(),
        '/login_page': (context) => const LoginPage(),
        '/register_page': (context) => const RegisterPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/product_page') {
          final productId = settings.arguments as int?;
          return MaterialPageRoute(
            builder: (context) {
              return ProductPage(productId: productId ?? 0);
            },
          );
        }
        return null; // Default return for unknown routes
      },
    );
  }
}