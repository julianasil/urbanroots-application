//lib\screens\product\edit_product_screen.dart
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List; 
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
import '../../providers/product_provider.dart';

class EditProductScreen extends StatefulWidget {
  final Product? product;

  const EditProductScreen({super.key, this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockQuantityController;
  late final TextEditingController _unitController;
  File? _imageFile;
  Uint8List? _imageBytes; 
  String? _imageName;
  String? _existingImage;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _descriptionController = TextEditingController(text: widget.product?.description ?? '');
    _priceController = TextEditingController(text: widget.product?.price.toString() ?? '');
    _stockQuantityController = TextEditingController(text: widget.product?.stockQuantity.toString() ?? '');
    _unitController = TextEditingController(text: widget.product?.unit ?? 'piece');
    _existingImage = widget.product?.image;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _stockQuantityController.dispose();
    _unitController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      // 1. Request the file, asking for byte data ONLY if on web.
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: kIsWeb,
      );

      // 2. Check if a result was returned.
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.single;
        
        // 3. Update the state in a platform-aware way.
        setState(() {
          _imageName = file.name;
          if (kIsWeb) {
            // If on web, we know `file.bytes` is not null because we requested it.
            _imageBytes = file.bytes;
            _imageFile = null;
          } else {
            // If not on web, we know `file.path` is not null.
            _imageFile = File(file.path!);
            _imageBytes = null;
          }
          _existingImage = null; // A new image was picked, clear the old one.
        });
      }
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: ${e.toString()}')),
        );
      }
    }
  }


  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final productProvider = Provider.of<ProductProvider>(context, listen: false);

    try {
      final productData = Product(
        productId: widget.product?.productId ?? '', // Use existing ID or empty for new
        name: _nameController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        stockQuantity: int.parse(_stockQuantityController.text),
        unit: _unitController.text,
        image: _existingImage ?? '', // Pass the existing image URL/path
        isActive: widget.product?.isActive ?? true, // Default to true for new products
      );

      if (widget.product == null) {
        // Create new product
        await productProvider.createProduct(productData, imageFile: _imageFile);
      } else {
        // Update existing product
        await productProvider.updateProduct(productData, imageFile: _imageFile);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product saved successfully!'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save product: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

   Widget _buildImagePreview() {
    if (_imageBytes != null) {
      // Preview from memory (web)
      return Image.memory(_imageBytes!, height: 150, width: double.infinity, fit: BoxFit.cover);
    }
    if (_imageFile != null) {
      // Preview from file (mobile)
      return Image.file(_imageFile!, height: 150, width: double.infinity, fit: BoxFit.cover);
    }
    if (_existingImage != null && _existingImage!.isNotEmpty) {
      // Preview from network
      final imageUrl = _existingImage!.startsWith('http') ? _existingImage! : 'http://127.0.0.1:8000$_existingImage';
      return Image.network(imageUrl, height: 150, width: double.infinity, fit: BoxFit.cover);
    }
      return Container(
        height: 150,
        width: double.infinity,
        color: Colors.grey[200],
        child: const Center(child: Text("No image selected")),
      );
    }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
        actions: [
          IconButton(
            icon: _isSaving
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveForm,
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
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
                validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter a price';
                  if (double.tryParse(value) == null) return 'Please enter a valid number';
                  return null;
                },
              ),
              TextFormField(
                controller: _stockQuantityController,
                decoration: const InputDecoration(labelText: 'Stock Quantity'),
                keyboardType: TextInputType.number,
                 validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter quantity';
                  if (int.tryParse(value) == null) return 'Please enter a whole number';
                  return null;
                },
              ),
              TextFormField(
                controller: _unitController,
                decoration: const InputDecoration(labelText: 'Unit (e.g., kg, piece, bundle)'),
                 validator: (value) => value!.isEmpty ? 'Please enter a unit' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 16),
              Text("Product Image", style: Theme.of(context).textTheme.titleMedium),
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
