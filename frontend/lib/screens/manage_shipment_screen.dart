// frontend/lib/screens/manage_shipment_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../models/shipment.dart';
import '../services/api_service.dart';
import '../providers/order_provider.dart';
import '../providers/user_provider.dart';

class ManageShipmentScreen extends StatefulWidget {
  final Order order;
  const ManageShipmentScreen({super.key, required this.order});

  @override
  State<ManageShipmentScreen> createState() => _ManageShipmentScreenState();
}

class _ManageShipmentScreenState extends State<ManageShipmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();
  
  // State variables
  List<LogisticsProvider> _providers = [];
  LogisticsProvider? _selectedProvider;
  final _trackingNumberController = TextEditingController();
  final Set<String> _selectedItemIds = {}; // Holds the IDs of the items to ship
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchProviders();
    // Pre-select all of this seller's un-shipped items in the order
    final sellerProfileId = Provider.of<UserProvider>(context, listen: false).activeBusinessProfile?.profileId;
    widget.order.items.forEach((item) {
      if (item.sellerProfile?.profileId == sellerProfileId && item.shipmentId == null) {
        _selectedItemIds.add(item.orderItemId);
      }
    });
  }
  
  Future<void> _fetchProviders() async {
    setState(() => _isLoading = true);
    try {
      _providers = await _apiService.getLogisticsProviders();
    } catch (e) {
      // Handle error
    }
    setState(() => _isLoading = false);
  }

  Future<void> _createShipment() async {
    if (!_formKey.currentState!.validate() || _selectedProvider == null || _selectedItemIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select items, a provider, and enter a tracking number.')),
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      await _apiService.createShipment(
        orderId: widget.order.orderId,
        orderItemIds: _selectedItemIds.toList(),
        logisticsProviderId: _selectedProvider!.providerId,
        trackingNumber: _trackingNumberController.text,
      );
      // Refresh the sales list to show the new 'shipped' status
      await Provider.of<OrderProvider>(context, listen: false).fetchAndSetSales();
      if (mounted) {
        Navigator.of(context).pop(); // Go back to the seller dashboard
      }
    } catch (e) {
      // Show error
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final sellerProfileId = Provider.of<UserProvider>(context, listen: false).activeBusinessProfile?.profileId;
    // Filter to show only the items this seller is responsible for in this order
    final sellerItems = widget.order.items.where((item) => item.sellerProfile?.profileId == sellerProfileId).toList();

    return Scaffold(
      appBar: AppBar(title: Text('Create Shipment')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Order #${widget.order.orderId.substring(0, 8)}', style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 16),
                    const Text('Select items to include in this shipment:', style: TextStyle(fontWeight: FontWeight.bold)),
                    ...sellerItems.map((item) {
                      return CheckboxListTile(
                        title: Text(item.product?.name ?? 'N/A'),
                        subtitle: Text('${item.quantity} x ₱${item.priceAtPurchase}'),
                        value: _selectedItemIds.contains(item.orderItemId),
                        onChanged: item.shipmentId != null ? null : (bool? value) {
                          setState(() {
                            if (value == true) {
                              _selectedItemIds.add(item.orderItemId);
                            } else {
                              _selectedItemIds.remove(item.orderItemId);
                            }
                          });
                        },
                      );
                    }).toList(),
                    const Divider(height: 32),
                    DropdownButtonFormField<LogisticsProvider>(
                      value: _selectedProvider,
                      hint: const Text('Select Logistics Provider'),
                      items: _providers.map((provider) {
                        return DropdownMenuItem(value: provider, child: Text(provider.name));
                      }).toList(),
                      onChanged: (provider) => setState(() => _selectedProvider = provider),
                      validator: (value) => value == null ? 'Please select a provider.' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _trackingNumberController,
                      decoration: const InputDecoration(labelText: 'Tracking Number'),
                      validator: (value) => value!.isEmpty ? 'Please enter a tracking number.' : null,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _createShipment,
                        child: const Text('Create Shipment & Mark as Shipped'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}