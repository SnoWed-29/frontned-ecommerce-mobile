import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import 'auth_service.dart'; // Import AuthService
import 'dart:io';
import 'dart:typed_data'; // For using Uint8List on web

class ProductService {
  static const String _baseUrl = 'http://127.0.0.1:8000/api';
  final AuthService _authService = AuthService(); // Create an instance of AuthService

  // Fetch product details by ID
  Future<Map<String, dynamic>> fetchProductDetails(int productId) async {
    final url = '$_baseUrl/product/$productId';
    final token = await _authService.getToken(); // Get the token from AuthService

    if (token == null) {
      throw Exception('No token found. Please log in.');
    }

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token', // Include token in the header
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load product details');
      }
    } catch (e) {
      throw Exception('Failed to load product details: $e');
    }
  }
  // Fetch all products
  Future<List<Product>> fetchProducts() async {
    final token = await _authService.getToken(); // Get the token from AuthService

    if (token == null) {
      throw Exception('No token found. Please log in.');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/products'),
      headers: {
        'Authorization': 'Bearer $token', // Include token in the header
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  // Fetch all categories
  Future<List<String>> fetchCategories() async {
    final token = await _authService.getToken(); // Get the token from AuthService

    if (token == null) {
      throw Exception('No token found. Please log in.');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/categories'),
      headers: {
        'Authorization': 'Bearer $token', // Include token in the header
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data
          .map<String>((category) => category['name'] as String)
          .toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  // Add product to cart
  Future<void> addToCart(int userId, int productId, int quantity) async {
    final token = await _authService.getToken(); // Get the token from AuthService

    if (token == null) {
      throw Exception('No token found. Please log in.');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/added-tocart'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Include token in the header
      },
      body: json.encode({
        'user_id': userId,
        'product_id': productId,
        'quantity': quantity,
      }),
    );

    if (response.statusCode == 200) {
      print('Product added to cart');
    } else {
      print('Failed to add product to cart');
    }
  }

  // Fetch products by category
  Future<List<Product>> fetchProductsByCategory(int categoryId) async {
    final token = await _authService.getToken(); // Get the token from AuthService

    if (token == null) {
      throw Exception('No token found. Please log in.');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/products-category/$categoryId'),
      headers: {
        'Authorization': 'Bearer $token', // Include token in the header
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((productJson) => Product.fromJson(productJson)).toList();
    } else {
      throw Exception('Failed to load products for category $categoryId');
    }
  }

  // Fetch cart items
  Future<List<dynamic>> fetchCartItems(int userId) async {
    final token = await _authService.getToken(); // Get the token from AuthService

    if (token == null) {
      throw Exception('No token found. Please log in.');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/cart/$userId'),
      headers: {
        'Authorization': 'Bearer $token', // Include token in the header
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load cart items');
    }
  }

  // Add a new product
  Future<void> addProduct({
    required String name,
    required String description,
    required double price,
    required List<int> categoryIds,
    required List<dynamic> imagePaths, // This will hold File (mobile) and Uint8List (web)
    required int userId, // Add the userId parameter here
  }) async {
    final token = await _authService.getToken(); // Get the token from AuthService

    if (token == null) {
      throw Exception('No token found. Please log in.');
    }

    final uri = Uri.parse('$_baseUrl/products');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token';

    // Add form fields
    request.fields['name'] = name;
    request.fields['description'] = description;
    request.fields['price'] = price.toString();
    request.fields['user_id'] = userId.toString(); // Add the userId field
    for (var i = 0; i < categoryIds.length; i++) {
      request.fields['categories[$i]'] = categoryIds[i].toString();
    }

    // Add image files
    for (var image in imagePaths) {
      if (image is File) {
        // For mobile: add the file path
        request.files.add(await http.MultipartFile.fromPath('images[]', image.path));
      } else if (image is Uint8List) {
        // For web: add the image byte data
        request.files.add(http.MultipartFile.fromBytes('images[]', image, filename: 'image.png'));
      }
    }

    final response = await request.send();

    if (response.statusCode == 201) {
      print('Product added successfully');
    } else {
      final responseBody = await response.stream.bytesToString();
      print('Failed to add product: ${response.reasonPhrase}, Response: $responseBody');
      throw Exception('Failed to add product');
    }
  }

  // Search products by query
  Future<List<Product>> searchProducts(String query) async {
    final token = await _authService.getToken(); // Get the token from AuthService

    if (token == null) {
      throw Exception('No token found. Please log in.');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/products/search?query=$query'),
      headers: {
        'Authorization': 'Bearer $token', // Include token in the header
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['products'];
      return data.map((productJson) => Product.fromJson(productJson)).toList();
    } else {
      throw Exception('Failed to search products. Error: ${response.body}');
    }
  }

  // Delete product from cart
  Future<Map<String, dynamic>> deleteProductFromCart(int cartId, int productId) async {
    final token = await _authService.getToken(); // Get the token from AuthService

    if (token == null) {
      throw Exception('No token found. Please log in.');
    }

    final url = '$_baseUrl/cart/$cartId/product/$productId';

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token', // Include token in the header
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body); // Return the response body
      } else {
        throw Exception('Failed to delete product: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error deleting product: $e');
    }
  }

  // Fetch user products
  Future<List<Product>> fetchUserProducts() async {
    final userId = await _authService.getUserId(); // Get the userId from AuthService

    if (userId == null) {
      throw Exception('User is not logged in');
    }

    final token = await _authService.getToken(); // Get the token from AuthService

    if (token == null) {
      throw Exception('No token found. Please log in.');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/user-products/$userId'),
      headers: {
        'Authorization': 'Bearer $token', // Include token in the header
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Product.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load user products');
    }
  }



// Delete a product by ID
Future<void> deleteProduct(int productId) async {
  final token = await _authService.getToken(); // Get the token from AuthService

  if (token == null) {
    throw Exception('No token found. Please log in.');
  }

  final url = '$_baseUrl/products/$productId';

  try {
    final response = await http.delete(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token', // Include token in the header
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      print('Product deleted successfully');
    } else {
      final responseBody = json.decode(response.body);
      throw Exception('Failed to delete product: ${responseBody['message']}');
    }
  } catch (e) {
    throw Exception('Error deleting product: $e');
  }
}
Future<Map<String, dynamic>> createOrder(
    String address,
    String postalCode,
    String city,
    double totalPrice,
  ) async {
    final token = await _authService.getToken(); // Get the token from AuthService
    final userId = await _authService.getUserId(); // Get the user ID from AuthService

    if (token == null || userId == null) {
      throw Exception('No token or user ID found. Please log in.');
    }

    // final url = 'https://your-api-url.com/orders'; // Replace with your API endpoint
    final url = '$_baseUrl/orders';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token', // Include token in the header
          'Accept': 'application/json',
          'Content-Type': 'application/json', // Ensure content-type is set to application/json
        },
        body: jsonEncode({
          'user_id': userId, // Use the user_id from the AuthService
          'Address': address,
          'postal_code': postalCode,
          'city': city,
          'total_price': totalPrice, // Ensure the total price is sent if required by the backend
        }),
      );

      if (response.statusCode == 201) {
        // If the response is successful (201 Created), return the response body
        return jsonDecode(response.body);
      } else {
        // Handle non-success status codes
        final responseBody = json.decode(response.body);
        throw Exception('Failed to create order: ${responseBody['message']}');
      }
    } catch (e) {
      // Catch any errors and throw a specific exception
      throw Exception('Error creating order: $e');
    }
  }

}