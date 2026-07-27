import 'package:get/get.dart';
import 'api_provider.dart';

class AuthProvider extends ApiProvider {
  Future<Response> login(String email, String password, {String? fcmToken}) {
    return post('/auth/login', {
      'email': email,
      'password': password,
      if (fcmToken != null) 'fcm_token': fcmToken,
    });
  }

  Future<Response> logout() {
    return post('/auth/logout', {});
  }

  Future<Response> getProfile() {
    return get('/auth/me');
  }
}
