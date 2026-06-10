class ProfileNotFoundException implements Exception {
  final String userId;

  const ProfileNotFoundException(this.userId);

  @override
  String toString() => 'Profile with id: $userId not found';
}
