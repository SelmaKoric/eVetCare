enum NotificationType { appointment, health, payment, service }

class NotificationItem {
  final int notificationId;
  final int userId;
  final String message;
  final DateTime dateTimeSent;
  final bool isRead;

  NotificationItem({
    required this.notificationId,
    required this.userId,
    required this.message,
    required this.dateTimeSent,
    required this.isRead,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      notificationId: json['notificationId'] ?? 0,
      userId: json['userId'] ?? 0,
      message: json['message'] ?? '',
      dateTimeSent:
          DateTime.tryParse(json['dateTimeSent'] ?? '') ?? DateTime.now(),
      isRead: json['isRead'] ?? false,
    );
  }

  int get id => notificationId;
  String get title => _extractTitleFromMessage();
  DateTime get timestamp => dateTimeSent;
  NotificationType get type => _determineTypeFromMessage();

  String _extractTitleFromMessage() {
    if (message.toLowerCase().contains('reminder')) {
      return 'Appointment Reminder';
    } else if (message.toLowerCase().contains('confirmed')) {
      return 'Appointment Confirmed';
    } else if (message.toLowerCase().contains('cancelled')) {
      return 'Appointment Cancelled';
    } else if (message.toLowerCase().contains('payment')) {
      return 'Payment Update';
    } else {
      return 'Notification';
    }
  }

  NotificationType _determineTypeFromMessage() {
    if (message.toLowerCase().contains('appointment')) {
      return NotificationType.appointment;
    } else if (message.toLowerCase().contains('payment')) {
      return NotificationType.payment;
    } else if (message.toLowerCase().contains('health') ||
        message.toLowerCase().contains('vaccination')) {
      return NotificationType.health;
    } else {
      return NotificationType.service;
    }
  }
}
