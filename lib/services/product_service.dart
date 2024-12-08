import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ProductService {
  static const String _baseUrl = 'http://127.0.0.1:8000/products';

  // Fetch all products
  Future<List<Product>> fetchProducts() async {
  final response = await http.get(Uri.parse(_baseUrl));

  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);
    print('Fetched products: $data');  // Check the response here
    return data.map((json) => Product.fromJson(json)).toList();
  } else {
    throw Exception('Failed to load products');
  }
}
}