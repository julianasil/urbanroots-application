// frontend/lib/screens/edit_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../providers/user_provider.dart';
// MODIFIED: Changed from ApiService to the new, dedicated service
import '../services/business_profile_service.dart';

class EditProfileScreen extends StatefulWidget {
  final BusinessProfile? profile;
  final bool isEmbedded;

  const EditProfileScreen({
    super.key,
    this.profile,
    this.isEmbedded = false,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  // MODIFIED: Using the new, dedicated service
  final _profileService = BusinessProfileService();

  late final TextEditingController _companyNameController;
  late final TextEditingController _contactNumberController;
  late final TextEditingController _addressController;
  String _businessType = 'buyer';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _companyNameController = TextEditingController(text: widget.profile?.companyName ?? '');
    _contactNumberController = TextEditingController(text: widget.profile?.contactNumber ?? '');
    _addressController = TextEditingController(text: widget.profile?.address ?? '');
    _businessType = widget.profile?.businessType ?? 'buyer';
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _contactNumberController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      final profileData = {
        'company_name': _companyNameController.text,
        'contact_number': _contactNumberController.text,
        'address': _addressController.text,
        'business_type': _businessType,
      };

      if (widget.profile == null) {
        // MODIFIED: Calling the correct method from the new service
        await _profileService.createProfile(profileData);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile created successfully!'), backgroundColor: Colors.green));
      } else {
        // MODIFIED: Calling the correct method from the new service
        await _profileService.updateProfile(widget.profile!.profileId, profileData);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated successfully!'), backgroundColor: Colors.green));
      }

      // After saving, refresh the user's list of business profiles
      await userProvider.fetchMyBusinessProfiles();

      if (mounted) {
        if (!widget.isEmbedded) {
          Navigator.of(context).pop(true);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formContent = SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.isEmbedded)
              const Padding(
                padding: EdgeInsets.only(bottom: 16.0),
                child: Text('Create a New Business', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              ),
            TextFormField(
              controller: _companyNameController,
              decoration: const InputDecoration(labelText: 'Company Name'),
              validator: (v) => v!.isEmpty ? 'Company name is required' : null,
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
            DropdownButtonFormField<String>(
              value: _businessType,
              decoration: const InputDecoration(labelText: 'I am a:'),
              items: const [
                DropdownMenuItem(value: 'buyer', child: Text('Buyer')),
                DropdownMenuItem(value: 'seller', child: Text('Seller')),
                DropdownMenuItem(value: 'both', child: Text('Both')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _businessType = value);
              },
            ),
            const SizedBox(height: 32),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _saveProfile,
                    child: Text(widget.profile == null ? 'Create Profile' : 'Save Changes'),
                  ),
          ],
        ),
      ),
    );

    if (widget.isEmbedded) {
      return formContent;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.profile == null ? 'Create Business Profile' : 'Edit Business Profile'),
      ),
      body: formContent,
    );
  }
}