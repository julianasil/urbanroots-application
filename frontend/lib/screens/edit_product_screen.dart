import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';

class EditProductScreen extends StatefulWidget {
  final Product? product;

  const EditProductScreen({super.key, this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _name;
  late String _description;
  late double _price;
  late int _stockQuantity;
  late String _unit;
  File? _imageFile;
  String? _existingImageUrl;

  @override
  void initState() {
    super.initState();
    _name = widget.product?.name ?? '';
    _description = widget.product?.description ?? '';
    _price = widget.product?.price ?? 0.0;
    _stockQuantity = widget.product?.stockQuantity ?? 0;
    _unit = widget.product?.unit ?? 'kg';

    final imageUrl = widget.product?.imageUrl ?? '';
    if (imageUrl.isNotEmpty) {
      if (imageUrl.startsWith("http")) {
        _existingImageUrl = imageUrl;
      } else {
        _imageFile = File(imageUrl);
      }
    }
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _imageFile = File(result.files.single.path!);
        _existingImageUrl = null;
      });
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final newProduct = Product(
        id: widget.product?.id ?? DateTime.now().toString(),
        name: _name,
        description: _description,
        price: _price,
        stockQuantity: _stockQuantity,
        unit: _unit,
        imageUrl: _imageFile?.path ?? _existingImageUrl ?? '',
        isActive: widget.product?.isActive ?? true,
      );

      final productProvider =
          Provider.of<ProductProvider>(context, listen: false);

      if (widget.product == null) {
        productProvider.addProduct(newProduct);
      } else {
        productProvider.updateProduct(newProduct); // <-- fixed
      }

      Navigator.of(context).pop();
    }
  }

  Widget _buildImagePreview() {
    if (_imageFile != null) {
      return Image.file(_imageFile!, height: 150, fit: BoxFit.cover);
    } else if (_existingImageUrl != null && _existingImageUrl!.isNotEmpty) {
      return Image.network(_existingImageUrl!, height: 150, fit: BoxFit.cover);
    } else {
      return const Text("No image selected");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter a name' : null,
                onSaved: (value) => _name = value!,
              ),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Description'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a description'
                    : null,
                onSaved: (value) => _description = value!,
              ),
              TextFormField(
                initialValue: _price.toString(),
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter a price' : null,
                onSaved: (value) => _price = double.parse(value!),
              ),
              TextFormField(
                initialValue: _stockQuantity.toString(),
                decoration: const InputDecoration(labelText: 'Stock Quantity'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter stock quantity'
                    : null,
                onSaved: (value) => _stockQuantity = int.parse(value!),
              ),
              TextFormField(
                initialValue: _unit,
                decoration: const InputDecoration(labelText: 'Unit'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter a unit' : null,
                onSaved: (value) => _unit = value!,
              ),
              const SizedBox(height: 16),
              Text("Product Image",
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _buildImagePreview(),
              TextButton.icon(
                icon: const Icon(Icons.image),
                label: const Text("Pick Image"),
                onPressed: _pickImage,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
