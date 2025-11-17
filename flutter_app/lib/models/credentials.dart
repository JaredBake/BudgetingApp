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

  int getUserId() {
    return userId;
  }

  String getName() {
    return name;
  }

  String getUserName() {
    return userName;
  }

  String getEmail() {
    return email;
  }
}
