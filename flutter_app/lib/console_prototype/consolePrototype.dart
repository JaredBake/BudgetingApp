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

User createUser() {

}


void main() {
  while (true) {
    stdout.writeln('''
==========================
  Budget Console (Prototype)
==========================
1) Create user
2) Create account
3) List accounts
4) Add fund
5) List funds
6) Add transaction
7) Show account balance
0) Exit
''');

    final choice = promptInt('Select: ');
    try {
      switch (choice) {
        case 1:
          createUserFlow();
          break;
        case 2:
          stdout.writeln('Goodbye!');
          return;
        case 3:
          stdout.writeln('Goodbye!');
          return;
        case 4:
          stdout.writeln('Goodbye!');
          return;
        case 5:
          stdout.writeln('Goodbye!');
          return;
        case 6:
          stdout.writeln('Goodbye!');
          return;
        case 7:
          stdout.writeln('Goodbye!');
          return;
        case 0:
          stdout.writeln('Goodbye!');
          return;
        default:
          stdout.writeln('Unknown option.');
      }
    } catch (e) {
      stderr.writeln('Error: $e\n');
    }
  }
}
// dart run lib/console_prototype/consolePrototype.dart