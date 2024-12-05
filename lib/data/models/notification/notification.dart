class NotificationModel {
  final String userId;
  final String senderId;
  final String message;

  NotificationModel({
    required this.userId,
    required this.senderId,
    required this.message,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      userId: json['user_id'],
      senderId: json['sender_id'],
      message: json['message'],
    );
  }
}