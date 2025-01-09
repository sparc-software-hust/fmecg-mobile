import 'package:equatable/equatable.dart';

//enum AuthenticationStatus { initial, success, unauthenticated, fail,loading }

abstract class AuthenticationState extends Equatable {
  @override
  List<Object> get props => [];
}

class AuthenticationInitial extends AuthenticationState {}

class AuthenticationLoading extends AuthenticationState {}

class AuthenticationSuccess extends AuthenticationState {
  //final UserModel? userModel;
  //AuthenticationSuccess({required this.userModel});
  AuthenticationSuccess();
}

class AuthenticationFail extends AuthenticationState {}
