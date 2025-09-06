// frontend/lib/screens/account_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../providers/user_provider.dart';
import '../services/api_service.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';
import '../widgets/claim_profile.dart'; // Make sure this import is present

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final ApiService _apiService = ApiService();
  late Future<UserProfile> _userProfileFuture;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  // Reloads the profile data from the API
  void _loadProfile() {
    setState(() {
      _userProfileFuture = _apiService.getMyProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // A soft background color
      appBar: AppBar(
        title: const Text('My Account'),
        elevation: 0,
      ),
      body: FutureBuilder<UserProfile>(
        future: _userProfileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error.toString()}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No profile data found.'));
          }

          final userProfile = snapshot.data!;

          // The main UI is a scrollable list
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            children: [
              // 1. A prominent header with the user's avatar and name
              _buildUserHeader(userProfile),
              const SizedBox(height: 24),

              // 2. A new, dedicated card for Personal Information
              _buildPersonalInfoCard(userProfile),
              const SizedBox(height: 24),

              // 3. The existing card for Business Information
              _buildBusinessInfoCard(userProfile),
              const SizedBox(height: 32),
              
              _buildLogoutButton(context),
            ],
          );
        },
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildUserHeader(UserProfile profile) {
    return Column(
      children: [
        CircleAvatar(
          radius: 45,
          child: Text(profile.fullName.isNotEmpty ? profile.fullName[0].toUpperCase() : '?'),
        ),
        const SizedBox(height: 12),
        Text(profile.fullName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        Text('@${profile.username}', style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }

  // --- NEW WIDGET ---
  // This widget displays the user's personal details in a clean card.
Widget _buildPersonalInfoCard(UserProfile profile) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      // FIX: The outer Padding was removed to match the other card.
      child: Padding(
        // FIX: Padding is now consistent with the business info card.
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FIX: The extra Padding around the title was removed.
            const Text('Personal Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8), // Added for spacing
            _InfoTile(icon: Icons.email_outlined, title: 'Email', subtitle: profile.email),
            _InfoTile(icon: Icons.person_outline, title: 'Full Name', subtitle: profile.fullName),
            _InfoTile(icon: Icons.shield_outlined, title: 'Role', subtitle: profile.role.capitalize()),
            const SizedBox(height: 16),
            // --- NEW FEATURE ---
            // Add a button to edit the personal profile.
            Center(
              child: OutlinedButton(
                onPressed: () {
                  // TODO: Create and navigate to an "Edit Personal Profile" screen.
                  // For now, we can just show a snackbar as a placeholder.
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Edit Personal Profile screen not yet implemented.')),
                  );
                },
                child: const Text('Edit Personal Info'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- NEW WIDGET ---
  // This widget now wraps the business profile logic.
  Widget _buildBusinessInfoCard(UserProfile profile) {
    final hasBusinessProfile = profile.businessProfile != null;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Business Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (hasBusinessProfile)
              _buildProfileDetails(profile.businessProfile!)
            else
              _buildCreateOrChooseProfilePrompt(),
          ],
        ),
      ),
    );
  }

  // Displays the details of an existing business profile
  Widget _buildProfileDetails(BusinessProfile profile) {
    return Column(
      children: [
        _InfoTile(icon: Icons.business, title: 'Company Name', subtitle: profile.companyName ?? 'N/A'),
        _InfoTile(icon: Icons.phone, title: 'Contact', subtitle: profile.contactNumber),
        _InfoTile(icon: Icons.location_on_outlined, title: 'Address', subtitle: profile.address),
        _InfoTile(icon: Icons.work_outline, title: 'Business Type', subtitle: profile.businessType.capitalize()),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () async {
            final result = await Navigator.push<bool>(context, MaterialPageRoute(builder: (context) => EditProfileScreen(profile: profile)));
            if (result == true) _loadProfile();
          },
          child: const Text('Edit Business Profile'),
        ),
      ],
    );
  }

  // Displays options for a user without a business profile
  Widget _buildCreateOrChooseProfilePrompt() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          const Text('Complete your setup to start buying or selling.', textAlign: TextAlign.center),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () async {
              final result = await Navigator.push<bool>(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
              if (result == true) _loadProfile();
            },
            child: const Text('Create a New Profile'),
          ),
          const SizedBox(height: 8),
          const Text('OR'),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _showClaimProfileSheet,
            child: const Text('Choose an Existing Profile'),
          ),
        ],
      ),
    );
  }

  // The method to show the bottom sheet for claiming a profile
  void _showClaimProfileSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows sheet to take up more height
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6, // Start at 60% of screen height
        maxChildSize: 0.9, // Can be dragged up to 90%
        builder: (_, controller) => ClaimProfileSheet(
          scrollController: controller,
          onProfileClaimed: () {
            Navigator.of(context).pop();
            _loadProfile();
          },
        ),
      ),
    );
  }

  // The logout button widget
  Widget _buildLogoutButton(BuildContext context) {
    return Center(
      child: TextButton.icon(
        icon: Icon(Icons.logout, color: Colors.red[700]),
        label: Text('Log Out', style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold)),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30),
          backgroundColor: Colors.red[50],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () async {
          await Provider.of<UserProvider>(context, listen: false).logout();
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
            );
          }
        },
      ),
    );
  }
}

// A reusable tile for displaying information consistently
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _InfoTile({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey[500], size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: Colors.grey[800])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}