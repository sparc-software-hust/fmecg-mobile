abstract class AuthenticationEvent {}

class LogInRequest extends AuthenticationEvent {
  final String email;
  final String password;
  LogInRequest({required this.email, required this.password});
}

class LogoutRequest extends AuthenticationEvent {}

class CheckAutoLogin extends AuthenticationEvent {}

