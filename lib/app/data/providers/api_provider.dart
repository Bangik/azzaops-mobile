import 'package:get/get.dart';
import '../../core/utils/constants.dart';
import '../../core/utils/storage_helper.dart';
import '../../routes/app_routes.dart';

class ApiProvider extends GetConnect {
  @override
  void onInit() {
    httpClient.baseUrl = Constants.baseUrl;
    httpClient.timeout = const Duration(seconds: Constants.connectTimeout);
    allowAutoSignedCert = true;

    // Add Bearer Token and Accept headers to each request
    httpClient.addRequestModifier<dynamic>((request) async {
      final token = StorageHelper.getToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      request.headers['Accept'] = 'application/json';
      return request;
    });

    // Handle 401 (Unauthorized) response → redirect to Login
    httpClient.addResponseModifier((request, response) {
      if (response.statusCode == 401) {
        StorageHelper.clearAll();
        Get.offAllNamed(AppRoutes.LOGIN);
      }
      return response;
    });
  }
}
