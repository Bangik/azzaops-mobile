import 'package:get/get.dart';
import 'api_provider.dart';

class WorkOrderProvider extends ApiProvider {
  Future<Response> getWorkOrders({String? status, String? date, int? page}) {
    final query = <String, String>{};
    if (status != null) query['status'] = status;
    if (date != null) query['date'] = date;
    if (page != null) query['page'] = page.toString();

    return get('/work-orders', query: query);
  }

  Future<Response> getWorkOrderDetail(int id) {
    return get('/work-orders/$id');
  }

  Future<Response> updateWorkOrderStatus(int id, String status, {String? notes}) {
    return put('/work-orders/$id/status', {
      'status': status,
      if (notes != null) 'notes': notes,
    });
  }

  Future<Response> getTodayWorkOrders() {
    return get('/work-orders/today');
  }
}
