import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/api_service.dart';

class ClaimProfileSheet extends StatefulWidget {
  final VoidCallback onProfileClaimed;
  final ScrollController? scrollController;

  const ClaimProfileSheet({super.key, required this.onProfileClaimed, this.scrollController,});

  @override
  State<ClaimProfileSheet> createState() => _ClaimProfileSheetState();
}

class _ClaimProfileSheetState extends State<ClaimProfileSheet> {
  final ApiService _apiService = ApiService();
  late Future<List<BusinessProfile>> _unclaimedProfilesFuture;

  @override
  void initState() {
    super.initState();
    _unclaimedProfilesFuture = _apiService.getUnclaimedProfiles();
  }

  Future<void> _claimProfile(String profileId) async {
    try {
      await _apiService.claimProfile(profileId);
      widget.onProfileClaimed(); // Trigger the callback on success
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Choose an Existing Profile', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Expanded(
            child: FutureBuilder<List<BusinessProfile>>(
              future: _unclaimedProfilesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No unclaimed profiles available.'));
                }

                final profiles = snapshot.data!;
                return ListView.builder(
                  controller: widget.scrollController,
                  itemCount: profiles.length,
                  itemBuilder: (context, index) {
                    final profile = profiles[index];
                    return Card(
                      child: ListTile(
                        title: Text(profile.companyName ?? 'Unnamed Profile'),
                        subtitle: Text(profile.address),
                        onTap: () => _claimProfile(profile.profileId),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}