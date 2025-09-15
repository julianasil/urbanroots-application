// lib/models/user_profile.dart

// Make sure your BusinessProfile class is also in this file or imported correctly.
// Its definition should not change.
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


// --- REPLACE YOUR UserProfile CLASS WITH THIS ONE ---
class UserProfile {
  final String id;
  final String email;
  final String username;
  final String firstName;       // ADDED
  final String lastName;        // ADDED
  final String fullName;
  final String? bio;             // ADDED
  final String? phoneNumber;     // ADDED
  final String? profilePicture;  // ADDED
  final String role;
  final List<BusinessProfile> businessProfiles; // MODIFIED

  UserProfile({
    required this.id,
    required this.email,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.fullName,
    this.bio,
    this.phoneNumber,
    this.profilePicture,
    required this.role,
    required this.businessProfiles,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    var profilesList = json['business_profiles'] as List? ?? [];
    List<BusinessProfile> profiles = profilesList.map((i) => BusinessProfile.fromJson(i)).toList();

    return UserProfile(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      fullName: json['full_name'] ?? '',
      bio: json['bio'],
      phoneNumber: json['phone_number'],
      profilePicture: json['profile_picture'],
      role: json['role'],
      businessProfiles: profiles,
    );
  }
}