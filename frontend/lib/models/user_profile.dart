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
      profileId: json['profile_id'],
      companyName: json['company_name'],
      contactNumber: json['contact_number'],
      address: json['address'],
      businessType: json['business_type'],
    );
  }
}

class UserProfile {
  final String id;
  final String email;
  final String username;
  final String fullName;
  final String role;
  // This can now be a BusinessProfile object or null
  final BusinessProfile? businessProfile;

  UserProfile({
    required this.id,
    required this.email,
    required this.username,
    required this.fullName,
    required this.role,
    this.businessProfile,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      fullName: json['full_name'],
      role: json['role'],
      // If 'business_profile' is not null in the JSON, parse it. Otherwise, it's null.
      businessProfile: json['business_profile'] != null
          ? BusinessProfile.fromJson(json['business_profile'])
          : null,
    );
  }
}

// A simple extension to capitalize the first letter of a string
extension StringExtension on String {
  String capitalize() {
    if (this.isEmpty) return this;
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}