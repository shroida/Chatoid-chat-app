mixin NotiRepo {
  Future<void> sendPushNotification(
      int receiverId, String message, String senderusername) async {}
}
