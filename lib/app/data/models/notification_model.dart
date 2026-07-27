import 'dart:convert';

class NotificationModel {
  final int id;
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final bool isRead;
  final String? readAt;
  final String createdAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.data,
    required this.isRead,
    this.readAt,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? dataPayload;
    if (json['data'] != null) {
      if (json['data'] is String) {
        try {
          dataPayload = jsonDecode(json['data'] as String) as Map<String, dynamic>;
        } catch (_) {}
      } else if (json['data'] is Map) {
        dataPayload = Map<String, dynamic>.from(json['data'] as Map);
      }
    }

    return NotificationModel(
      id: json['id'] as int,
      type: json['type'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      data: dataPayload,
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      readAt: json['read_at'] as String?,
      createdAt: (json['created_at'] ?? '') as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'title': title,
        'body': body,
        'data': data != null ? jsonEncode(data) : null,
        'is_read': isRead,
        'read_at': readAt,
        'created_at': createdAt,
      };
}
