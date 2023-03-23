import 'package:flutter/material.dart';

import '../../flutter_login.dart';
import '../models/login_data.dart';

enum AuthMode { Signup, Login }

/// The result is an error message, callback successes if message is null
typedef AuthCallback = Future<String?>? Function(LoginData);

/// The result is an error message, callback successes if message is null
typedef ProviderAuthCallback = Future<String?>? Function();

/// The result is an error message, callback successes if message is null
typedef RecoverCallback = Future<String?>? Function(String);

class Auth with ChangeNotifier {
  Auth({
    this.loginProviders = const [],
    this.onLogin,
    this.onSignup,
    this.onRecoverPassword,
    String email = '+886',
    String email_addr = '',
    String password = '',
    String confirmPassword = '',
    String legalName = '',
  })  : _email = email,
        _email_addr = email_addr,
        _password = password,
        _confirmPassword = confirmPassword,
        _legal_name = legalName;

  final AuthCallback? onLogin;
  final AuthCallback? onSignup;
  final RecoverCallback? onRecoverPassword;
  final List<LoginProvider> loginProviders;

  AuthMode _mode = AuthMode.Login;

  AuthMode get mode => _mode;
  set mode(AuthMode value) {
    _mode = value;
    notifyListeners();
  }

  bool get isLogin => _mode == AuthMode.Login;
  bool get isSignup => _mode == AuthMode.Signup;
  bool isRecover = false;

  AuthMode opposite() {
    return _mode == AuthMode.Login ? AuthMode.Signup : AuthMode.Login;
  }

  AuthMode switchAuth() {
    if (mode == AuthMode.Login) {
      mode = AuthMode.Signup;
      email = '';
    } else if (mode == AuthMode.Signup) {
      mode = AuthMode.Login;
      email = '+886';
    }
    return mode;
  }

  String _email = '';
  String get email => _email;
  set email(String email) {
    _email = email;
    notifyListeners();
  }

  String _email_addr = '';
  String get email_addr => _email_addr;
  set email_addr(String email_addr) {
    _email_addr = email_addr;
    notifyListeners();
  }

  String _legal_name = '';
  String get legal_name => _legal_name;
  set legal_name(String legal_name) {
    _legal_name = legal_name;
    notifyListeners();
  }

  String _password = '';
  String get password => _password;
  set password(String password) {
    _password = password;
    notifyListeners();
  }

  String _confirmPassword = '';
  String get confirmPassword => _confirmPassword;
  set confirmPassword(String confirmPassword) {
    _confirmPassword = confirmPassword;
    notifyListeners();
  }
}
