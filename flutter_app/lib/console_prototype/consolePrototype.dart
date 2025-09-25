import '../models/transaction.dart';
import '../models/money.dart';
import '../models/credentials.dart';
import '../models/account.dart';
import '../models/user.dart';
import '../models/fund.dart';
import '../models/data.dart';


Credentials createCredentials(int userId, String name, String userName, String password, String email) {

    Credentials creds = Credentials(
        userId: userId,
        name: name,
        userName: userName,
        password: password,
        email: email
    );
    return creds;
}

// User createUser() {

// }

void main() {
    Credentials creds = createCredentials(1, "John Doe", "johndoe", "password123", "john@example.com");

    print("User Created:");
    print("Name: ${creds.getName()}");
    print("User Name: ${creds.getUserName()}");
    print("Email: ${creds.getEmail()}");

}
// dart run lib/console_prototype/consolePrototype.dart