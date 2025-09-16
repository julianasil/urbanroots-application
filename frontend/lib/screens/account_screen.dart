// frontend/lib/screens/account_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../providers/user_provider.dart';
import 'business_selection_screen.dart';
import 'edit_profile_screen.dart'; // --- ADDED: Import the edit screen ---
import 'login_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  Widget build(BuildContext context) {
    // --- KEY CHANGE: Using a Consumer for cleaner state access ---
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        // --- KEY CHANGE: Getting the detailed user profile from our Django backend ---
        final userProfile = userProvider.user;
        final activeBusinessProfile = userProvider.activeBusinessProfile;

        // Show a loading indicator while the profile is being fetched.
        if (userProfile == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // The main UI builds once we have the user profile.
        return Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            title: const Text('My Account'),
            elevation: 0,
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            children: [
              _buildUserHeader(userProfile),
              const SizedBox(height: 24),
              // Pass context to the card to handle navigation
              _buildPersonalInfoCard(context, userProfile),
              const SizedBox(height: 24),
              _buildActiveBusinessCard(context, activeBusinessProfile),
              const SizedBox(height: 32),
              _buildLogoutButton(context),
            ],
          ),
        );
      },
    );
  }

  // --- WIDGET BUILDERS (with modifications) ---

  Widget _buildUserHeader(UserProfile profile) {
    // This widget can stay the same as fullName and username are available.
    return Column(
      children: [
        CircleAvatar(radius: 45, child: Text(profile.fullName.isNotEmpty ? profile.fullName[0].toUpperCase() : '?')),
        const SizedBox(height: 12),
        Text(profile.fullName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        Text('@${profile.username}', style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }

  // --- KEY CHANGE: This card is now updated to show new info and has a working button ---
  Widget _buildPersonalInfoCard(BuildContext context, UserProfile profile) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Personal Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _InfoTile(icon: Icons.email_outlined, title: 'Email', subtitle: profile.email),
            
            // --- ADDED: Display phone number if it exists ---
            if (profile.phoneNumber != null && profile.phoneNumber!.isNotEmpty)
              _InfoTile(icon: Icons.phone_outlined, title: 'Phone', subtitle: profile.phoneNumber!),

            // --- ADDED: Display bio if it exists ---
            if (profile.bio != null && profile.bio!.isNotEmpty)
              _InfoTile(icon: Icons.person_outline, title: 'Bio', subtitle: profile.bio!),

            const SizedBox(height: 16),
            Center(
              child: OutlinedButton(
                onPressed: () {
                  // --- ACTIVATED: Navigate to the EditProfileScreen ---
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (ctx) => const EditProfileScreen()),
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

  // No changes are needed for the widgets below this line.
  // ... (rest of your file: _buildActiveBusinessCard, _buildLogoutButton, _InfoTile, etc.)
  // The following is copied from your original file for completeness.

  Widget _buildActiveBusinessCard(BuildContext context, BusinessProfile? activeProfile) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Active Business Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            if (activeProfile != null)
              _buildProfileDetails(activeProfile)
            else
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    'No active business profile. Please select one to start selling.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Center(
              child: OutlinedButton(
                child: Text(activeProfile != null ? 'Switch or Manage Businesses' : 'Select a Business Profile'),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (ctx) => const BusinessSelectionScreen()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileDetails(BusinessProfile profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoTile(icon: Icons.business, title: 'Company Name', subtitle: profile.companyName ?? 'N/A'),
        _InfoTile(icon: Icons.phone, title: 'Contact', subtitle: profile.contactNumber),
        _InfoTile(icon: Icons.work_outline, title: 'Business Type', subtitle: profile.businessType), // Removed capitalize for simplicity
      ],
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return Center(
      child: TextButton.icon(
        icon: Icon(Icons.logout, color: Colors.red[700]),
        label: Text('Log Out', style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold)),
        style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 30), backgroundColor: Colors.red[50], shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
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