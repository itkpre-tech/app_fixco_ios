/// Represents a user's profile data returned from the API.
class ProfileModel {
  final String fullName;
  final String email;
  final String phone;
  final String memberSince;
  final int bookingsCount;
  final int completedCount;

  const ProfileModel({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.memberSince,
    required this.bookingsCount,
    required this.completedCount,
  });

  /// Constructs a [ProfileModel] from a raw API response map.
  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      fullName: map['full_name'] as String? ?? 'User',
      email: map['email'] as String? ?? '-',
      phone: map['phone'] as String? ?? '-',
      memberSince: map['member_since'] as String? ?? '-',
      bookingsCount: (map['bookings_count'] as int?) ?? 0,
      completedCount: (map['completed_count'] as int?) ?? 0,
    );
  }

  /// Returns the user's initials (up to 2 characters) derived from [fullName].
  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }
}