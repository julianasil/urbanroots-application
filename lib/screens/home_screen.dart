import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../widgets/product_tile.dart';
import 'cart_screen.dart';
// TODO: Replace this import with your actual edit/add product screen
import 'edit_product_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _isInit = true;
  var _isLoading = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<ProductProvider>(context, listen: false).fetchProducts().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
      _isInit = false;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final products = productProvider.filteredItems;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CartScreen()),
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                productProvider.updateSearch(value);
              },
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : products.isEmpty
              ? const Center(child: Text('No products found.'))
              : GridView.builder(
                  padding: const EdgeInsets.all(10.0),
                  itemCount: products.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 3 / 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (ctx, i) => ProductTile(product: products[i]),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const EditProductScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
