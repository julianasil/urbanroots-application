// lib/screens/product/edit_product_screen.dart
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product.dart';
//import '../../models/user_profile.dart';
import '../../providers/product_provider.dart';
import '../../providers/user_provider.dart';

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

  // REMOVED: The state variable for the selected profile is no longer needed.
  // BusinessProfile? _selectedBusinessProfile;

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
    // This method is already correct.
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: kIsWeb);
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.single;
        setState(() {
          _imageName = file.name;
          if (kIsWeb) {
            _imageBytes = file.bytes; _imageFile = null;
          } else {
            _imageFile = File(file.path!); _imageBytes = null;
          }
          _existingImage = null;
        });
      }
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error picking image: ${e.toString()}')));
    }
  }

  // MODIFIED: The save logic is now simpler.
  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    // Get the active profile from the provider.
    final activeProfile = Provider.of<UserProvider>(context, listen: false).activeBusinessProfile;

    // Guard clause: This should ideally never happen if the FAB logic is correct, but it's a good safety check.
    if (activeProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: No active business profile selected.'), backgroundColor: Colors.red));
      return;
    }

    setState(() => _isSaving = true);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);

    try {
      final productData = Product(
        productId: widget.product?.productId ?? '',
        sellerProfile: activeProfile, // CRITICAL: Use the ACTIVE profile's ID
        name: _nameController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        stockQuantity: int.parse(_stockQuantityController.text),
        unit: _unitController.text,
        image: _existingImage,
        isActive: widget.product?.isActive ?? true,
      );

      if (widget.product == null) {
        await productProvider.createProduct(productData, imageFile: _imageFile, imageBytes: _imageBytes, imageName: _imageName);
      } else {
        await productProvider.updateProduct(productData, imageFile: _imageFile, imageBytes: _imageBytes, imageName: _imageName);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Product saved successfully!'), backgroundColor: Colors.green));
        Navigator.of(context).pop();
      }
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save product: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _buildImagePreview() {
    // This method is already correct.
    if (_imageBytes != null) return Image.memory(_imageBytes!, height: 150, width: double.infinity, fit: BoxFit.cover);
    if (_imageFile != null) return Image.file(_imageFile!, height: 150, width: double.infinity, fit: BoxFit.cover);
    if (_existingImage != null && _existingImage!.isNotEmpty) {
      final imageUrl = _existingImage!.startsWith('http') ? _existingImage! : 'http://127.0.0.1:8000$_existingImage';
      return Image.network(imageUrl, height: 150, width: double.infinity, fit: BoxFit.cover);
    }
    return Container(height: 150, width: double.infinity, color: Colors.grey[200], child: const Center(child: Text("No image selected")));
  }
  
  // REMOVED: The dropdown widget is no longer needed.

  @override
  Widget build(BuildContext context) {
    // We still need the UserProvider to get the active profile.
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final activeProfile = userProvider.activeBusinessProfile;

    // If the user somehow gets here without an active seller profile, show an error view.
    if (activeProfile == null || (activeProfile.businessType != 'seller' && activeProfile.businessType != 'both')) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cannot Add Product')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'You must have an active "Seller" or "Both" type business profile selected to add a product.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        // Display which business they are adding a product to.
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(25.0),
          child: Text(
            'For: ${activeProfile.companyName}',
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // REMOVED: The dropdown is gone. The form starts with the product name.
              TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Product Name'), validator: (value) => value!.isEmpty ? 'Please enter a name' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _priceController, decoration: const InputDecoration(labelText: 'Price'), keyboardType: TextInputType.numberWithOptions(decimal: true), validator: (value) { if (value == null || value.isEmpty) return 'Please enter a price'; if (double.tryParse(value) == null) return 'Please enter a valid number'; return null; }),
              const SizedBox(height: 16),
              TextFormField(controller: _stockQuantityController, decoration: const InputDecoration(labelText: 'Stock Quantity'), keyboardType: TextInputType.number, validator: (value) { if (value == null || value.isEmpty) return 'Please enter quantity'; if (int.tryParse(value) == null) return 'Please enter a whole number'; return null; }),
              const SizedBox(height: 16),
              TextFormField(controller: _unitController, decoration: const InputDecoration(labelText: 'Unit (e.g., kg, piece, bundle)'), validator: (value) => value!.isEmpty ? 'Please enter a unit' : null),
              const SizedBox(height: 16),
              TextFormField(controller: _descriptionController, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3, keyboardType: TextInputType.multiline),
              const SizedBox(height: 16),
              Text("Product Image", style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              _buildImagePreview(),
              TextButton.icon(icon: const Icon(Icons.image), label: const Text("Pick Image"), onPressed: _pickImage),
              const SizedBox(height: 24),
              if (_isSaving) const Center(child: CircularProgressIndicator()) else ElevatedButton(onPressed: _saveForm, child: const Text('Save Product')),
            ],
          ),
        ),
      ),
    );
  }
}