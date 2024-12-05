class clsMessage {
  int senderId;
  int friendId;
  String messageText;
  DateTime createdAt;
  bool isRead;
  String? react;
  String? messsagReply;

  clsMessage({
    required this.senderId,
    required this.friendId,
    required this.messageText,
    required this.createdAt,
    required this.isRead,
    this.react,
    this.messsagReply,
  });

  Map<String, dynamic> toJson() => {
        'user_id': senderId,
        'friend_id': friendId,
        'message_text': messageText,
        'created_at': createdAt.toIso8601String(), // Convert to ISO string
        'is_read': isRead,
        'reaction': react,
        'message_reply':
            messsagReply, // Include message_reply in the JSON representation
      };

  // Create a clsMessage object from a JSON map
  factory clsMessage.fromJson(Map<String, dynamic> json) {
    return clsMessage(
      friendId: json['friend_id'] as int,
      senderId: json['user_id'] as int,
      messageText: json['message_text'] as String,
      createdAt: DateTime.parse(json['created_at']),
      isRead: json['is_read'] as bool,
      react: json['reaction'] as String?, // This could be null
      messsagReply: json['message_reply'] as String?,
    );
  }
}
