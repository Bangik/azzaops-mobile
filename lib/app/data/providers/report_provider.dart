import 'package:get/get.dart';
import 'api_provider.dart';

class ReportProvider extends ApiProvider {
  Future<Response> submitReport(int workOrderId, FormData form) {
    return post('/work-orders/$workOrderId/reports', form);
  }

  Future<Response> getReports(int workOrderId) {
    return get('/work-orders/$workOrderId/reports');
  }

  Future<Response> getMyReports({int? page}) {
    final query = <String, String>{};
    if (page != null) query['page'] = page.toString();
    return get('/reports/my', query: query);
  }
}
