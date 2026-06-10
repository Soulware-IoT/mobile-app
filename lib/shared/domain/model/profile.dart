class Profile {
  final String id;
  final String fullName;
  final String email;
  final String? avatarUrl;

  const Profile({
    required this.id,
    required this.fullName,
    required this.email,
    this.avatarUrl,
  });
}