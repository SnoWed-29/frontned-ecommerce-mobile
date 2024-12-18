import 'package:flutter/material.dart';
import 'package:frontned/services/product_service.dart'; // Assuming your service is here

class OrderConfirmationPage extends StatefulWidget {
  final int userId;
  final double totalPrice;

  const OrderConfirmationPage({Key? key, required this.userId, required this.totalPrice}) : super(key: key);

  @override
  _OrderConfirmationPageState createState() => _OrderConfirmationPageState();
}

class _OrderConfirmationPageState extends State<OrderConfirmationPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  // Create an order
  Future<void> _confirmOrder() async {
    try {
      final response = await ProductService().createOrder(
        _addressController.text,
        _postalCodeController.text,
        _cityController.text,
        widget.totalPrice,
      );

      if (response['message'] == 'Order created successfully') {
        // Show success message and navigate to ShopPage with a success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order created successfully!')),
        );
        
        // Navigate back to the ShopPage after a successful order
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushReplacementNamed(context, '/shop_page');
        });
      } else {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create order: ${response['message']}')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create order: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Order'),
        backgroundColor: Colors.teal, // Use primary color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Amount: \$${widget.totalPrice.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal[900], // Teal text for clarity
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _addressController,
                maxLines: 5, // Makes the Address field like a textarea
                decoration: const InputDecoration(
                  labelText: 'Address',
                  labelStyle: TextStyle(color: Colors.teal), // Teal text for labels
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal),
                  ),
                  border: OutlineInputBorder(), // Gives a border for textarea style
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Address is required' : null,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _postalCodeController,
                decoration: const InputDecoration(
                  labelText: 'Postal Code',
                  labelStyle: TextStyle(color: Colors.teal), // Teal text for labels
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal),
                  ),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Postal code is required' : null,
              ),
              TextFormField(
                controller: _cityController,
                decoration: const InputDecoration(
                  labelText: 'City',
                  labelStyle: TextStyle(color: Colors.teal), // Teal text for labels
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal),
                  ),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'City is required' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    _confirmOrder();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal, // Primary color for the button
                ),
                child: const Text(
                  'Confirm Order',
                  style: TextStyle(color: Colors.white, fontSize: 16), // White text on button
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.teal[50], // Light teal background color
    );
  }
}