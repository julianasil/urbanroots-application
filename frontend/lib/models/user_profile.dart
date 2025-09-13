// frontend/lib/models/user_profile.dart

class BusinessProfile {
  final String profileId;
  final String? companyName;
  final String contactNumber;
  final String address;
  final String businessType;

  BusinessProfile({
    required this.profileId,
    this.companyName,
    required this.contactNumber,
    required this.address,
    required this.businessType,
  });

  factory BusinessProfile.fromJson(Map<String, dynamic> json) {
    return BusinessProfile(
      profileId: json['profile_id'] ?? '',
      companyName: json['company_name'],
      contactNumber: json['contact_number'] ?? '',
      address: json['address'] ?? '',
      businessType: json['business_type'] ?? 'buyer',
    );
  }

  // MODIFIED: Added these overrides. This is important for the UI, especially
  // for DropdownButton to correctly compare and display the selected item.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BusinessProfile &&
          runtimeType == other.runtimeType &&
          profileId == other.profileId;

  @override
  int get hashCode => profileId.hashCode;
}

class UserProfile {
  final String id;
  final String email;
  final String username;
  final String fullName;
  final String role;
  
  // REMOVED: The direct link to a single business profile is gone.
  // A user's business memberships are now fetched separately via the new API endpoint.
  // final BusinessProfile? businessProfile;

  UserProfile({
    required this.id,
    required this.email,
    required this.username,
    required this.fullName,
    required this.role,
    // REMOVED: No longer part of the constructor
    // this.businessProfile,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      username: json['username'] ?? '',
      fullName: json['full_name'] ?? '',
      role: json['role'] ?? 'user',
      // REMOVED: The logic for parsing a single business profile is gone.
    );
  }
}

// This extension is fine and can stay as is.
extension StringExtension on String {
  String capitalize() {
    if (this.isEmpty) return this;
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}