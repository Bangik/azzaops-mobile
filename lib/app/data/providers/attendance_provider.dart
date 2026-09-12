import 'package:get/get.dart';
import 'api_provider.dart';

class AttendanceProvider extends ApiProvider {
  Future<Response> getToday() => get('/attendances/today');

  Future<Response> checkIn({String? notes, required double latitude, required double longitude}) => post('/attendances/check-in', {
        if (notes != null && notes.isNotEmpty) 'notes': notes,
        'latitude': latitude,
        'longitude': longitude,
      });

  Future<Response> checkOut({String? notes, required double latitude, required double longitude}) => post('/attendances/check-out', {
        if (notes != null && notes.isNotEmpty) 'notes': notes,
        'latitude': latitude,
        'longitude': longitude,
      });

  Future<Response> getMyLog({String? from, String? to, int page = 1}) {
    final query = <String, String>{'page': '$page'};
    if (from != null) query['from'] = from;
    if (to != null) query['to'] = to;
    return get('/attendances/my-log', query: query);
  }
}
