import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/inventory_provider.dart';
import '../providers/product_provider.dart'; // ✅ add this import

class EditInventoryScreen extends StatefulWidget {
  final Product? product; // null = adding new

  const EditInventoryScreen({Key? key, this.product}) : super(key: key);

  @override
  _EditInventoryScreenState createState() => _EditInventoryScreenState();
}

class _EditInventoryScreenState extends State<EditInventoryScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _unitController = TextEditingController();
  final _stockController = TextEditingController();
  final _imageUrlController = TextEditingController();
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      // Pre-fill fields for editing
      _nameController.text = widget.product!.name;
      _descriptionController.text = widget.product!.description;
      _priceController.text = widget.product!.price.toString();
      _unitController.text = widget.product!.unit;
      _stockController.text = widget.product!.stockQuantity.toString();
      _imageUrlController.text = widget.product!.imageUrl;
      _isActive = widget.product!.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _unitController.dispose();
    _stockController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (!_formKey.currentState!.validate()) return;

    final inventoryProvider =
        Provider.of<InventoryProvider>(context, listen: false);
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);

    final newProduct = Product(
      productId: widget.product?.productId ?? DateTime.now().toString(), // temp id
      sellerProfileId: widget.product?.sellerProfileId ?? "s1", // placeholder seller
      name: _nameController.text,
      description: _descriptionController.text,
      price: double.parse(_priceController.text),
      unit: _unitController.text,
      stockQuantity: int.parse(_stockController.text),
      imageUrl: _imageUrlController.text.isNotEmpty
          ? _imageUrlController.text
          : "https://via.placeholder.com/150",
      isActive: _isActive,
    );

    if (widget.product == null) {
      // Add new
      inventoryProvider.addItem(newProduct);
      productProvider.addProduct(newProduct); // ✅ sync with product page
    } else {
      // Update existing
      inventoryProvider.updateItem(newProduct);
      productProvider.updateProduct(newProduct); // ✅ sync with product page
    }

    Navigator.of(context).pop(); // go back to inventory screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null
            ? "Add Inventory Item"
            : "Edit Inventory Item"),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Name"),
                validator: (value) =>
                    value == null || value.isEmpty ? "Please enter a name." : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: "Price"),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return "Please enter a price.";
                  if (double.tryParse(value) == null) return "Enter a valid number.";
                  return null;
                },
              ),
              TextFormField(
                controller: _unitController,
                decoration:
                    const InputDecoration(labelText: "Unit (e.g., kg, pack)"),
              ),
              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(labelText: "Stock Quantity"),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return "Please enter stock.";
                  if (int.tryParse(value) == null) return "Enter a valid number.";
                  return null;
                },
              ),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: "Image URL"),
              ),
              SwitchListTile(
                title: const Text("Active"),
                value: _isActive,
                onChanged: (val) {
                  setState(() {
                    _isActive = val;
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveForm,
                child: const Text("Save"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
