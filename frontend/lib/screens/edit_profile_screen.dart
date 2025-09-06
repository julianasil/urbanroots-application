// frontend/lib/screens/edit_profile_screen.dart
import 'package:flutter/material.dart';
import '../models/user_profile.dart'; // We'll need this to pass existing data
import '../services/api_service.dart';

class EditProfileScreen extends StatefulWidget {
  // If we are editing, we pass the existing profile. If creating, this will be null.
  final BusinessProfile? profile;

  const EditProfileScreen({super.key, this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = ApiService();

  late final TextEditingController _companyNameController;
  late final TextEditingController _contactNumberController;
  late final TextEditingController _addressController;
  String _businessType = 'buyer'; // Default value

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill the form fields if we are editing an existing profile
    _companyNameController = TextEditingController(text: widget.profile?.companyName ?? '');
    _contactNumberController = TextEditingController(text: widget.profile?.contactNumber ?? '');
    _addressController = TextEditingController(text: widget.profile?.address ?? '');
    _businessType = widget.profile?.businessType ?? 'buyer';
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() { _isLoading = true; });

    try {
      final profileData = {
        'company_name': _companyNameController.text,
        'contact_number': _contactNumberController.text,
        'address': _addressController.text,
        'business_type': _businessType,
      };

      if (widget.profile == null) {
        // We are creating a new profile
        await _apiService.createMyProfile(profileData);
      } else {
        // We are updating an existing profile (You'll need to add this method to ApiService)
        // await _apiService.updateMyProfile(profileData); 
        print("Update logic to be implemented"); // Placeholder for now
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved successfully!'), backgroundColor: Colors.green),
        );
        // Go back to the previous screen
        Navigator.of(context).pop(true); // Pop with 'true' to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.profile == null ? 'Create Business Profile' : 'Edit Business Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _companyNameController,
                decoration: const InputDecoration(labelText: 'Company Name (Optional)'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contactNumberController,
                decoration: const InputDecoration(labelText: 'Contact Number'),
                validator: (value) => value!.isEmpty ? 'Please enter a contact number' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? 'Please enter an address' : null,
              ),
              const SizedBox(height: 24),
              const Text('I am a:', style: TextStyle(fontWeight: FontWeight.bold)),
              DropdownButton<String>(
                value: _businessType,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'buyer', child: Text('Buyer')),
                  DropdownMenuItem(value: 'seller', child: Text('Seller')),
                  DropdownMenuItem(value: 'both', child: Text('Both')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() { _businessType = value; });
                  }
                },
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _saveProfile,
                      child: const Text('Save Profile'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}