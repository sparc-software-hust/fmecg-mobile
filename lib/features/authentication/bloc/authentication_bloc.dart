import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:fmecg_mobile/features/authentication/bloc/authentication_event.dart';
import 'package:fmecg_mobile/features/authentication/bloc/authentication_state.dart';
import 'package:fmecg_mobile/features/authentication/repository/authentication_repo.dart';
import 'package:fmecg_mobile/features/authentication/repository/shared_pref_repo.dart';
import 'package:fmecg_mobile/providers/user_provider.dart';
import 'package:fmecg_mobile/utils/utils.dart';
import 'package:provider/provider.dart';

class AuthenticationBloc extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc({required this.authRepository}) : super(AuthenticationInitial()) {
    on<LogInRequest>(_onLoginRequest);
    on<LogoutRequest>(_onLogoutRequest);
    on<CheckAutoLogin>(_onCheckAutoLogin);
  }
  final AuthRepository authRepository;
  void _onLoginRequest(LogInRequest event, Emitter emit) async {
    try {
      final Map? response = await authRepository.loginUser(event.email, event.password);
      if (response == null) {
        emit(AuthenticationFail());
        return;
      }
      final Map dataUser = response["metadata"];
      SharedPreprerencesRepo.setDataUser(dataUser);
      Provider.of<UserProvider>(Utils.globalContext!, listen: false).setDataUser(dataUser);
      emit(AuthenticationSuccess());
    } catch (e) {
      emit(AuthenticationFail());
    }
  }

  void _onLogoutRequest(LogoutRequest event, Emitter emit) async {
    try {
      SharedPreprerencesRepo.removeDataUser();
      emit(AuthenticationFail());
    } catch (e) {
      emit(AuthenticationFail());
    }
  }
  void _onCheckAutoLogin(CheckAutoLogin event, Emitter emit) async {
    try {
      emit(AuthenticationLoading());
      final bool hasLoggedIn = await SharedPreprerencesRepo.checkAutoLogin();
      print(hasLoggedIn);
      if (hasLoggedIn) {
        final String dataLoginString = await SharedPreprerencesRepo.getDataUser();
         print("dataLoginDecode: $dataLoginString 123123");
        final Map dataLoginDecoded = jsonDecode(dataLoginString);
       
        Provider.of<UserProvider>(Utils.globalContext!, listen: false).setDataUser(dataLoginDecoded);
        emit(AuthenticationSuccess());
      } else {
        emit(AuthenticationInitial());
      }
    } catch (e, t) {
      print('dgndfgj:$e $t');
      emit(AuthenticationFail());
    }
  }
}
