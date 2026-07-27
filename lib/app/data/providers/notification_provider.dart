import 'package:get/get.dart';
import 'api_provider.dart';

class NotificationProvider extends ApiProvider {
  Future<Response> getNotifications({int? page}) {
    final query = <String, String>{};
    if (page != null) query['page'] = page.toString();
    return get('/notifications', query: query);
  }

  Future<Response> markAsRead(int id) {
    return put('/notifications/$id/read', {});
  }

  Future<Response> markAllAsRead() {
    return put('/notifications/read-all', {});
  }

  Future<Response> getUnreadCount() {
    return get('/notifications/unread-count');
  }
}
