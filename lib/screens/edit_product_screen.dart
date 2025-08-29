// lib/screens/edit_product_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/product_provider.dart';
import '../widgets/product_image.dart';

class EditProductScreen extends StatefulWidget {
  final Product? existingProduct;

  const EditProductScreen({Key? key, this.existingProduct}) : super(key: key);

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imageUrlController = TextEditingController();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();

  // sample asset images (ensure these are present and registered in pubspec.yaml)
  final List<String> _sampleImages = const [
    'assets/images/sample1.jpg',
    'assets/images/sample2.jpg',
    'assets/images/sample3.jpg',
  ];

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.existingProduct;
    _titleController.text = p?.title ?? '';
    _descController.text = p?.description ?? '';
    _priceController.text = p != null ? p.price.toStringAsFixed(2) : '';
    _imageUrlController.text = p?.imageUrl ?? '';
  }

  @override
  void dispose() {
    _imageUrlController.dispose();
    _titleController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _chooseSample(String path) {
    // set the asset path into controller and refresh preview
    setState(() => _imageUrlController.text = path);
  }

  Widget _buildPreviewCard(String imagePath) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: 200,
        child: ProductImage(
          imageUrl: imagePath.isNotEmpty ? imagePath : null,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 200,
        ),
      ),
    );
  }

  Future<void> _saveForm() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    setState(() => _isSaving = true);

    final title = _titleController.text.trim();
    final description = _descController.text.trim();
    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final imageUrl = _imageUrlController.text.trim();

    final newProduct = Product(
      id: widget.existingProduct?.id ?? UniqueKey().toString(),
      title: title,
      description: description,
      price: price,
      imageUrl: imageUrl,
    );

    final provider = Provider.of<ProductProvider>(context, listen: false);
    if (widget.existingProduct == null) {
      provider.addProduct(newProduct);
    } else {
      provider.updateProduct(newProduct);
    }

    // small delay to make save feel tactile (optional)
    await Future.delayed(const Duration(milliseconds: 200));

    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product saved')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingProduct != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Product' : 'Add Product'),
        centerTitle: true,
      ),

      // Use a ListView so the screen scrolls gracefully on small devices
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
          child: Form(
            key: _formKey,
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: [
                // Preview
                _buildPreviewCard(_imageUrlController.text),

                const SizedBox(height: 12),

                // Image URL field + clear button
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _imageUrlController,
                        decoration: const InputDecoration(
                          labelText: 'Image URL or asset path',
                          hintText: 'https://... or assets/images/sample1.jpg',
                          prefixIcon: Icon(Icons.link),
                        ),
                        keyboardType: TextInputType.url,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Clear',
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() => _imageUrlController.clear());
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Sample images selector
                const Text('Or pick a sample image:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 88,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _sampleImages.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (ctx, i) {
                      final path = _sampleImages[i];
                      final selected = _imageUrlController.text == path;
                      return GestureDetector(
                        onTap: () => _chooseSample(path),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: 120,
                          decoration: BoxDecoration(
                            border: Border.all(color: selected ? Theme.of(context).colorScheme.primary : Colors.grey.shade300, width: selected ? 2 : 1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.asset(path, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image))),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 18),

                // Title
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    prefixIcon: Icon(Icons.label_important_outline),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Please enter a title' : null,
                ),

                const SizedBox(height: 12),

                // Description
                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    prefixIcon: Icon(Icons.description_outlined),
                  ),
                  maxLines: 3,
                  keyboardType: TextInputType.multiline,
                  validator: (v) => v == null || v.trim().isEmpty ? 'Please enter a description' : null,
                ),

                const SizedBox(height: 12),

                // Price
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price',
                    prefixIcon: Icon(Icons.attach_money_outlined),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (v) {
                    final text = v ?? '';
                    final parsed = double.tryParse(text.trim());
                    if (parsed == null || parsed <= 0) return 'Enter a valid price';
                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // optional helper text
                Text(
                  'Tip: leave Image field blank to use the placeholder image.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),

                const SizedBox(height: 80), // extra space so content doesn't hide behind button
              ],
            ),
          ),
        ),
      ),

      // sticky Save button
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            onPressed: _isSaving ? null : _saveForm,
            icon: _isSaving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white))) : const Icon(Icons.save),
            label: Text(_isSaving ? 'Saving...' : isEdit ? 'Save Changes' : 'Add Product'),
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
      ),
    );
  }
}
