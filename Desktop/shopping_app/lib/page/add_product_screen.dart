import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // ✅ For Clipboard access
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController(); // New Sale Price
  final _oldPriceController = TextEditingController(); // Original Price
  final _descController = TextEditingController();
  final _urlController = TextEditingController();

  bool _isLoading = false;

  // ✅ Category Selection
  String selectedCategory = 'Shoes'; // default
  final List<String> categories = ['Shoes', 'Clothes', 'Bags', 'Accessories'];

  // ✅ Helper to paste directly from Clipboard
  Future<void> _pasteFromClipboard() async {
    ClipboardData? data = await Clipboard.getData('text/plain');
    if (data != null && data.text != null) {
      setState(() {
        _urlController.text = data.text!;
      });
    }
  }

  Future<void> _saveProduct() async {
    if (_nameController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _oldPriceController.text.isEmpty ||
        _urlController.text.isEmpty) {
      _showSnackBar(
        "Please fill all fields, including prices",
        Colors.redAccent,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;

      await FirebaseFirestore.instance.collection('products').add({
        'title': _nameController.text.trim(),
        'price': double.parse(_priceController.text.trim()), // Sale Price
        'oldPrice': double.parse(_oldPriceController.text.trim()), // Original Price
        'description': _descController.text.trim(),
        'imageUrl': _urlController.text.trim(),
        'sellerId': user?.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'category': selectedCategory, // ✅ Save selected category
      });

      if (mounted) {
        _showSnackBar("Product Posted Successfully!", Colors.green);
        Navigator.pop(context);
      }
    } catch (e) {
      _showSnackBar("Error: ${e.toString()}", Colors.redAccent);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Add New Product",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color.fromRGBO(254, 206, 1, 1),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- IMAGE PREVIEW ---
                  const Text(
                    "Image Preview",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(245, 247, 249, 1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: _urlController.text.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              _urlController.text,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Center(
                                child: Text(
                                  "Invalid or Broken URL",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.link_off,
                                size: 50,
                                color: Colors.grey,
                              ),
                              Text(
                                "Enter a URL to see preview",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 25),

                  // --- URL INPUT FIELD ---
                  TextField(
                    controller: _urlController,
                    onChanged: (value) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: "Paste Image URL",
                      hintText: "https://...",
                      prefixIcon: const Icon(Icons.link_rounded),
                      suffixIcon: IconButton(
                        icon: const Icon(
                          Icons.content_paste_rounded,
                          color: Colors.blue,
                        ),
                        onPressed: _pasteFromClipboard,
                        tooltip: "Paste from clipboard",
                      ),
                      filled: true,
                      fillColor: const Color.fromRGBO(245, 247, 249, 1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),

                  _buildTextField("Product Name", _nameController, Icons.title),
                  const SizedBox(height: 15),
                  _buildTextField(
                      "Original Price (Birr)", _oldPriceController, Icons.history,
                      isNumber: true),
                  const SizedBox(height: 15),
                  _buildTextField(
                      "Sale Price (ETB)", _priceController, Icons.payments_outlined,
                      isNumber: true),
                  const SizedBox(height: 15),
                  _buildTextField(
                      "Description", _descController, Icons.description_outlined,
                      maxLines: 3),
                  const SizedBox(height: 20),

                  // --- CATEGORY DROPDOWN ---
                  const Text(
                    "Select Category",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(245, 247, 249, 1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: DropdownButton<String>(
                      value: selectedCategory,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: categories.map((cat) {
                        return DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => selectedCategory = value);
                      },
                    ),
                  ),
                  const SizedBox(height: 30),

                  // --- SUBMIT BUTTON ---
                  ElevatedButton(
                    onPressed: _saveProduct,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(254, 206, 1, 1),
                      foregroundColor: Colors.black,
                      minimumSize: const Size.fromHeight(60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "POST TO MARKET",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: const Color.fromRGBO(245, 247, 249, 1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
