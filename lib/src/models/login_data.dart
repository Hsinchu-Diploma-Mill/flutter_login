import 'package:quiver/core.dart';

class LoginData {
  final String name;
  final String password;
  final String? email;
  final String? legalName;

  LoginData(
      {required this.name, required this.password, this.email, this.legalName});

  @override
  String toString() {
    return '$runtimeType($name, $password, $email, $legalName)';
  }

  @override
  bool operator ==(Object other) {
    if (other is LoginData) {
      return name == other.name &&
          password == other.password &&
          email == other.email &&
          legalName == other.legalName;
    }
    return false;
  }

  @override
  int get hashCode => hash4(name, password, email, legalName);
}
