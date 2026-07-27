import 'package:get/get.dart';
import 'api_provider.dart';

class ProfileProvider extends ApiProvider {
  Future<Response> getProfile() {
    return get('/profile');
  }

  Future<Response> updateProfile(String name, String? phone) {
    return put('/profile', {
      'name': name,
      if (phone != null) 'phone': phone,
    });
  }

  Future<Response> updatePassword(
    String currentPassword,
    String password,
    String passwordConfirmation,
  ) {
    return put('/profile/password', {
      'current_password': currentPassword,
      'password': password,
      'password_confirmation': passwordConfirmation,
    });
  }

  Future<Response> updateFcmToken(String fcmToken) {
    return put('/profile/fcm-token', {
      'fcm_token': fcmToken,
    });
  }
}
