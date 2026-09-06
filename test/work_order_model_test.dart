import 'package:flutter_test/flutter_test.dart';
import 'package:azzaops_mobile/app/data/models/work_order_model.dart';

void main() {
  test('parse work order with duration fields', () {
    final Map<dynamic, dynamic> raw = {
      "id": 5,
      "wo_number": "WO-20260811-0003",
      "work_order_type_id": 2,
      "customer_id": 1,
      "service_category_id": 5,
      "title": "Cuci AC Split",
      "location": "Jl. Sudirman No. 10",
      "scheduled_date": "2026-08-10T17:00:00.000000Z",
      "scheduled_time": "04:45:00",
      "job_order": 41,
      "started_at": "2026-08-11T05:00:00.000000Z",
      "completed_at": "2026-08-11T06:30:00.000000Z",
      "duration": "1 jam 30 menit",
      "duration_minutes": 90,
      "status": "completed",
      "customer": <dynamic, dynamic>{
        "id": 1,
        "type": "individual",
        "name": "Dalton Perez",
        "phone": "+1 (476) 147-7341",
      },
      "service_category": <dynamic, dynamic>{
        "id": 5,
        "name": "Cuci AC",
        "is_active": true,
      },
      "type": <dynamic, dynamic>{
        "id": 2,
        "name": "Servis",
        "code": "service",
        "is_active": true,
      },
      "items": [],
      "assignments": [],
      "reports": [],
      "takeovers": []
    };

    final model = WorkOrderModel.fromJson(Map<String, dynamic>.from(raw));
    expect(model.id, 5);
    expect(model.duration, "1 jam 30 menit");
    expect(model.durationMinutes, 90);
  });
}
