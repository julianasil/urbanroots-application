// frontend/lib/screens/account_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../providers/user_provider.dart';
import 'business_selection_screen.dart';
import 'login_screen.dart';

// MODIFIED: Changed back to a StatefulWidget
class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  Widget build(BuildContext context) {
    // We get the providers here
    final userProvider = Provider.of<UserProvider>(context);
    final supabaseUser = userProvider.currentUser;

    if (supabaseUser == null) {
      // It's good practice to show a scaffold even when loading
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final userProfile = UserProfile(
      id: supabaseUser.id,
      email: supabaseUser.email ?? 'No Email',
      username: supabaseUser.userMetadata?['username'] ?? 'No Username',
      fullName: supabaseUser.userMetadata?['full_name'] ?? 'No Name',
      role: 'user',
    );
    
    final activeBusinessProfile = userProvider.activeBusinessProfile;

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
          _buildPersonalInfoCard(userProfile),
          const SizedBox(height: 24),
          _buildActiveBusinessCard(context, activeBusinessProfile),
          const SizedBox(height: 32),
          _buildLogoutButton(context),
        ],
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildUserHeader(UserProfile profile) {
    return Column(
      children: [
        CircleAvatar(radius: 45, child: Text(profile.fullName.isNotEmpty ? profile.fullName[0].toUpperCase() : '?')),
        const SizedBox(height: 12),
        Text(profile.fullName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        Text('@${profile.username}', style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildPersonalInfoCard(UserProfile profile) {
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
            _InfoTile(icon: Icons.shield_outlined, title: 'Role', subtitle: profile.role.capitalize()),
            const SizedBox(height: 16),
            Center(
              child: OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Edit Personal Profile screen not yet implemented.')));
                },
                child: const Text('Edit Personal Info'),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
        _InfoTile(icon: Icons.work_outline, title: 'Business Type', subtitle: profile.businessType.capitalize()),
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
          // 'context' is available here because we are in the State class
          await Provider.of<UserProvider>(context, listen: false).logout();
          
          // 'mounted' is available here because this is a StatefulWidget
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