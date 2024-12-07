import 'package:flutter/material.dart';
import 'package:frontned/pages/cart_page.dart';
import 'package:frontned/pages/category_page.dart';
import 'package:frontned/pages/product_page.dart';
import 'package:frontned/pages/shop_page.dart';
import 'package:frontned/themes/light_mode.dart';
import 'package:frontned/pages/intro_page.dart';

// Define a sample product
final Map<String, String> product = {
  'name': 'Sample Product',
  'price': '\$129.00',
  'image': 'assets/images/image01.jpg',
};

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const IntroPage(),
      theme: lightMode,
      routes: {
        '/intro_page': (context) => const IntroPage(),
        '/shop_page': (context) => const ShopPage(),
        '/cart_page': (context) => const CartPage(),
        '/category_page': (context) => CategoryPage(),
        '/product_page': (context) =>
            ProductPage(product: product), // Pass the sample product
      },
    );
  }
}
