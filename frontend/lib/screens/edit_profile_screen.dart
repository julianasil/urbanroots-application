// frontend/lib/screens/edit_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// --- MODIFIED: We will need the user service now ---
import '../services/user_service.dart'; 
import '../providers/user_provider.dart';

// --- MODIFIED: The screen no longer needs to accept a BusinessProfile ---
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  // --- MODIFIED: Use the UserService ---
  final _userService = UserService();

  // --- NEW: Controllers for the user's personal info ---
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _bioController;
  late final TextEditingController _phoneNumberController;
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // --- MODIFIED: Populate controllers with the current user's data ---
    final user = Provider.of<UserProvider>(context, listen: false).user;
    
    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
    _phoneNumberController = TextEditingController(text: user?.phoneNumber ?? '');
  }

  @override
  void dispose() {
    // --- MODIFIED: Dispose the new controllers ---
    _firstNameController.dispose();
    _lastNameController.dispose();
    _bioController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  // --- REWRITTEN: This method now saves the USER profile ---
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final userProvider = Provider.of<UserProvider>(context, listen: false);

    try {
      // Create a map of the data to send to the API.
      final profileData = {
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'bio': _bioController.text,
        'phone_number': _phoneNumberController.text,
      };

      // We will create the `updateUserProfile` methods in the service and provider next.
      await userProvider.updateUserProfile(profileData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: Colors.green,
        ));
        Navigator.of(context).pop(); // Go back to the previous screen
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- REWRITTEN: The entire form is new ---
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Your Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
                validator: (v) => v!.isEmpty ? 'First name is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
                validator: (v) => v!.isEmpty ? 'Last name is required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneNumberController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(labelText: 'Bio'),
                maxLines: 4,
              ),
              const SizedBox(height: 32),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _saveProfile,
                      child: const Text('Save Changes'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}