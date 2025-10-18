class Credentials {
  final int userId;
  final String name;
  final String userName;
  final String email;

  Credentials({
    required this.userId,
    required this.name,

    // TODO: Add username validation
    required this.userName,

    // TODO: Add email validation
    required this.email,
  });

  String getName() {
    return this.name;
  }

  String getUserName() {
    return this.userName;
  }

  String getEmail() {
    return this.email;
  }
}
