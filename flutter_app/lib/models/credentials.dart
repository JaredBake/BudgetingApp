class Credentials {
    final String name;
    final String userName;
    final String password;
    final String email;

    Credentials({
        required this.name, 

        // TODO: Add username validation
        required this.userName, 
        required this.password, 

        // TODO: Add email validation
        required this.email});

    String getName() {
        return this.name;
    }
    String getUserName() {
        return this.userName;
    }

    String getPassword() {
        return this.password;
    }

    String getEmail() {
        return this.email;
    }
}

