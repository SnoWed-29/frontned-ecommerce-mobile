import 'dart:convert'; // For JSON decoding
import 'dart:html' as html; // For web file handling
import 'package:flutter/foundation.dart'; // For checking platform (web/mobile)
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http; // For making API calls
import '../services/product_service.dart';

// Mobile imports
import 'dart:io' show File; // Mobile-only import

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final ProductService _productService = ProductService();

  String _name = '';
  String _description = '';
  double _price = 0.0;
  List<int> _selectedCategories = []; // Store selected category IDs
  List<dynamic> _images = []; // This will hold both File (mobile) and Uint8List (web)
  List<Uint8List> _imageBytes = []; // For web support
  final ImagePicker _picker = ImagePicker();

  // Store categories as a map of {id: name}
  Map<int, String> _categories = {}; 

  @override
  void initState() {
    super.initState();
    _fetchCategories(); // Fetch categories when the widget is initialized
  }

  // Fetch categories from ProductService
  Future<void> _fetchCategories() async {
    try {
      final categories = await _productService.fetchCategories(); // Get category names as List<String>
      setState(() {
        _categories = categories.asMap().map((index, name) => MapEntry(index + 1, name)); // Map category names to IDs
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load categories: $e')),
      );
    }
  }

  // For Mobile: Pick Image from Gallery
  void _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
    }
  }

 // For Web: Pick Image
// For Web: Pick Image
void _pickImageForWeb() async {
  html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
  uploadInput.accept = 'image/*';
  uploadInput.click();

  uploadInput.onChange.listen((e) async {
    final files = uploadInput.files;
    if (files!.isEmpty) return;

    final reader = html.FileReader();
    reader.readAsDataUrl(files[0] as html.File);
    reader.onLoadEnd.listen((e) {
      final base64String = reader.result as String;
      final base64Data = base64String.split(',').last; // Remove the "data:image/jpeg;base64," part
      final imageBytes = base64.decode(base64Data); // Decode to Uint8List
      setState(() {
        _imageBytes.add(imageBytes); // Add the Uint8List to your list
      });
    });
  });
}
  // Submit Form
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        List<dynamic> imagePaths = [];
        if (kIsWeb) {
          // For Web: Send the image data (Uint8List)
          for (var imageByte in _imageBytes) {
            imagePaths.add(imageByte);
          }
        } else {
          // For Mobile: Send the file paths (File)
          imagePaths = _images.map((file) {
            if (file is File) return file; // Add File objects
            return null;
          }).toList();
        }

        await _productService.addProduct(
          name: _name,
          description: _description,
          price: _price,
          categoryIds: _selectedCategories, // Pass the selected category IDs
          imagePaths: imagePaths,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product added successfully!',
                style: TextStyle(color: Colors.teal)),
            backgroundColor: Colors.white,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add product: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product', style: TextStyle(color: Colors.teal)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.teal),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Name Field
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  labelStyle: TextStyle(color: Colors.teal),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal),
                  ),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a product name' : null,
                onSaved: (value) => _name = value!,
              ),
              const SizedBox(height: 12),

              // Description Field
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(color: Colors.teal),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal),
                  ),
                ),
                maxLines: 3,
                onSaved: (value) => _description = value!,
              ),
              const SizedBox(height: 12),

              // Price Field
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Price',
                  labelStyle: TextStyle(color: Colors.teal),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal),
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || double.tryParse(value) == null
                        ? 'Please enter a valid price'
                        : null,
                onSaved: (value) => _price = double.parse(value!),
              ),
              const SizedBox(height: 12),

              // Category Selection (Collapsible dropdown)
              const Text('Select Categories', style: TextStyle(color: Colors.teal)),
              const SizedBox(height: 8),
              ExpansionTile(
                title: const Text('Categories'),
                children: _categories.entries.map((entry) {
                  return CheckboxListTile(
                    title: Text(entry.value),
                    value: _selectedCategories.contains(entry.key),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value!) {
                          _selectedCategories.add(entry.key); // Store category ID
                        } else {
                          _selectedCategories.remove(entry.key); // Remove category ID
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),

              // Image Picking Button
              ElevatedButton.icon(
                onPressed: () {
                  if (kIsWeb) {
                    _pickImageForWeb();
                  } else {
                    _pickImage();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.teal,
                  side: const BorderSide(color: Colors.teal),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                icon: const Icon(Icons.photo_library, color: Colors.teal),
                label: const Text('Pick from Gallery'),
              ),
              const SizedBox(height: 12),

              // Display selected images
              if (kIsWeb) ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _imageBytes
                      .map((image) => ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(image, width: 100, height: 100),
                          ))
                      .toList(),
                ),
              ] else ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _images
                      .map((image) => ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: (image is File)
                                ? Image.file(image, width: 100, height: 100)
                                : Container(), // Fallback for web
                          ))
                      .toList(),
                ),
              ],
              const SizedBox(height: 20),

              // Submit Button
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}