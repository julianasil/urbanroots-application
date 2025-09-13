// lib/screens/business_selection_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../providers/user_provider.dart';
import '../services/user_service.dart';
import 'edit_profile_screen.dart';

class BusinessSelectionScreen extends StatelessWidget {
  const BusinessSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Manage Businesses'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Select or Join'),
              Tab(text: 'Create New'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            SelectOrJoinBusinessTab(),
            CreateBusinessTab(),
          ],
        ),
      ),
    );
  }
}

class SelectOrJoinBusinessTab extends StatelessWidget {
  const SelectOrJoinBusinessTab({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final myBusinesses = userProvider.myBusinessProfiles;
    final activeBusiness = userProvider.activeBusinessProfile;

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text('My Business Profiles', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (userProvider.isLoadingProfiles)
          const Center(child: CircularProgressIndicator())
        else if (myBusinesses.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 24.0),
            child: Center(child: Text('You are not a member of any business yet.')),
          )
        else
          ...myBusinesses.map((profile) {
            final bool isActive = profile.profileId == activeBusiness?.profileId;
            return Card(
              color: isActive ? Colors.green[50] : null,
              child: ListTile(
                title: Text(profile.companyName ?? 'Unnamed Business'),
                subtitle: Text(profile.businessType.capitalize()),
                trailing: isActive ? const Icon(Icons.check_circle, color: Colors.green) : const Icon(Icons.radio_button_unchecked),
                onTap: () {
                  userProvider.setActiveBusinessProfile(profile);
                  ScaffoldMessenger.of(context)..hideCurrentSnackBar()..showSnackBar(SnackBar(content: Text('Switched to ${profile.companyName}')));
                },
              ),
            );
          }).toList(),
        
        const Divider(height: 40),

        const Center(child: Text('Join Another Business', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500))),
        const SizedBox(height: 8),
        Center(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.add_business_outlined),
            label: const Text('Join an Existing Business'),
            onPressed: () => _showJoinProfileSheet(context),
          ),
        ),
      ],
    );
  }

  void _showJoinProfileSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false, initialChildSize: 0.7, maxChildSize: 0.9,
        builder: (_, controller) => JoinProfileSheet(scrollController: controller),
      ),
    );
  }
}

class CreateBusinessTab extends StatelessWidget {
  const CreateBusinessTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const EditProfileScreen(isEmbedded: true);
  }
}


class JoinProfileSheet extends StatefulWidget {
  final ScrollController scrollController;
  const JoinProfileSheet({super.key, required this.scrollController});

  @override
  State<JoinProfileSheet> createState() => _JoinProfileSheetState();
}

class _JoinProfileSheetState extends State<JoinProfileSheet> {
  late Future<List<BusinessProfile>> _joinableProfilesFuture;

  @override
  void initState() {
    super.initState();
    // MODIFIED: Calling the CORRECT, renamed service method
    _joinableProfilesFuture = UserService().fetchJoinableBusinessProfiles();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return Material(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Join an Existing Business', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Select a business from the list to become a member.', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<List<BusinessProfile>>(
                future: _joinableProfilesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                  if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                  final joinableProfiles = snapshot.data ?? [];
                  if (joinableProfiles.isEmpty) return const Center(child: Text('No business profiles found to join.'));
                  
                  return ListView.builder(
                    controller: widget.scrollController,
                    itemCount: joinableProfiles.length,
                    itemBuilder: (context, index) {
                      final profile = joinableProfiles[index];
                      return Card(
                        child: ListTile(
                          title: Text(profile.companyName ?? 'Unnamed Business'),
                          subtitle: Text(profile.address),
                          onTap: () async {
                            try {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: const Text('Confirm Join'),
                                  content: Text('Are you sure you want to join "${profile.companyName}"?'),
                                  actions: [
                                    TextButton(child: const Text('Cancel'), onPressed: () => Navigator.of(ctx).pop(false)),
                                    TextButton(child: const Text('Join'), onPressed: () => Navigator.of(ctx).pop(true)),
                                  ],
                                ),
                              );

                              if (confirmed == true && mounted) {
                                // MODIFIED: Calling the CORRECT, renamed provider method
                                await userProvider.joinBusinessProfile(profile.profileId);
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Successfully joined profile!')));
                              }
                            } catch (e) {
                              if (mounted) {
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
                              }
                            }
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}