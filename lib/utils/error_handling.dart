import 'package:fmecg_mobile/generated/l10n.dart';

extension ErrorMessage on S {
  String getErrorMessage(Object error) {
    ArgumentError.checkNotNull(error);

    if (error is String) {
      return error;
    }

    // app errors
    // if (error is NotCompletedLoginException) {
    //   return requiredUpdatingYourProfile;
    // }
    // if (error is NotLoggedInException) {
    //   return notLoggedIn;
    // }
    // if (error is NotVerifiedEmail) {
    //   return yourAccountEmailHasNotBeenVerifyPleaseVerifyTo;
    // }
    // if (error is WrongRoleException) {
    //   return onlyUserRoleIsAllowed;
    // }

    // server error

    // network error
    // if (error is SocketException) {
    //   return noInternetConnection;
    // }
    // if (error is TimeoutException) {
    //   return hello;
    // }
    // if (error is HttpException) {
    //   return networkError;
    // }
    // if (error is ClientException) {
    //   return networkError;
    // }

    // firebase & platform errors
    // if (error is FirebaseAuthException) {
    //   return error.message ?? _unknownError;
    // }
    // if (error is PlatformException) {
    //   return error.message ?? _unknownError;
    // }

    return error.toString();
  }
}
