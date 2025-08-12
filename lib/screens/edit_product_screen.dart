import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';

class EditProductScreen extends StatefulWidget {
  final Product? existingProduct;

  const EditProductScreen({Key? key, this.existingProduct}) : super(key: key);

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imageUrlController = TextEditingController();

  late String _title;
  late String _description;
  late double _price;

  final List<String> _sampleImages = [
  'assets/images/sample1.jpg',
  'assets/images/sample2.jpg',
  'assets/images/sample3.jpg',
];


  @override
  void initState() {
    super.initState();
    _title = widget.existingProduct?.title ?? '';
    _description = widget.existingProduct?.description ?? '';
    _price = widget.existingProduct?.price ?? 0.0;
    _imageUrlController.text = widget.existingProduct?.imageUrl ?? '';
  }

  @override
  void dispose() {
    _imageUrlController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final newProduct = Product(
        id: widget.existingProduct?.id ?? UniqueKey().toString(),
        title: _title,
        description: _description,
        price: _price,
        imageUrl: _imageUrlController.text.trim(),
      );

      final provider = Provider.of<ProductProvider>(context, listen: false);
      if (widget.existingProduct == null) {
        provider.addProduct(newProduct);
      } else {
        provider.updateProduct(newProduct);
      }

      Navigator.of(context).pop();
    }
  }

  void _chooseSample(String path) {
    setState(() {
      _imageUrlController.text = path;
    });
  }

  Widget _buildPreview(String value) {
    if (value.startsWith('assets/')) {
      return Image.asset(value, fit: BoxFit.cover);
    }
    if (value.startsWith('http')) {
      return Image.network(
        value,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            const Center(child: Icon(Icons.broken_image)),
      );
    }
    return const Center(child: Icon(Icons.image_not_supported));
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingProduct != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Product' : 'Add Product'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveForm),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(labelText: 'Title'),
                onSaved: (value) => _title = value!,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Description'),
                onSaved: (value) => _description = value!,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                initialValue: _price != 0 ? _price.toString() : '',
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                onSaved: (value) => _price = double.tryParse(value!) ?? 0.0,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Required';
                  final parsed = double.tryParse(value);
                  if (parsed == null || parsed <= 0) {
                    return 'Enter valid price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image URL or asset path',
                  hintText: 'https://example.com/image.jpg',
                ),
              ),
              const SizedBox(height: 8),
              const Text('Pick a sample image:'),
              const SizedBox(height: 8),
              SizedBox(
                height: 90,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _sampleImages.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (ctx, i) {
                    final path = _sampleImages[i];
                    final selected = _imageUrlController.text == path;
                    return GestureDetector(
                      onTap: () => _chooseSample(path),
                      child: Container(
                        width: 140,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: selected ? Colors.green : Colors.grey,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(path, fit: BoxFit.cover),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              const Text('Preview:'),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: _imageUrlController.text.isNotEmpty
                    ? _buildPreview(_imageUrlController.text)
                    : const Center(
                        child: Text(
                          'No image selected - placeholder will be used',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
