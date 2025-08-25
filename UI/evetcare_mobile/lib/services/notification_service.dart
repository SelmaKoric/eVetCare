import 'package:flutter/material.dart';
import '../models/notification.dart';
import '../providers/api_provider.dart';

class NotificationService {
  // Get all notifications for the current user
  static Future<List<NotificationItem>> getNotifications() async {
    final response = await ApiProvider.getNotifications();

    List<NotificationItem> notifications = [];
    for (var notification in response) {
      notifications.add(NotificationItem.fromJson(notification));
    }

    return notifications;
  }

  // Mark a single notification as read
  static Future<void> markAsRead(int notificationId) async {
    await ApiProvider.markNotificationAsRead(notificationId);
  }

  // Mark multiple notifications as read
  static Future<void> markMultipleAsRead(List<int> notificationIds) async {
    for (final notificationId in notificationIds) {
      await ApiProvider.markNotificationAsRead(notificationId);
    }
  }

  // Cancel appointment from notification
  static Future<void> cancelAppointment(int appointmentId) async {
    await ApiProvider.cancelAppointment(appointmentId);
  }

  // Extract appointment ID from notification message
  static int? extractAppointmentIdFromMessage(String message) {
    final regex = RegExp(r'appointment\s+#?(\d+)', caseSensitive: false);
    final match = regex.firstMatch(message);

    if (match != null) {
      return int.tryParse(match.group(1) ?? '');
    }

    final numberRegex = RegExp(r'\b(\d+)\b');
    final numberMatch = numberRegex.firstMatch(message);

    if (numberMatch != null) {
      return int.tryParse(numberMatch.group(1) ?? '');
    }

    return null;
  }

  // Filter notifications by type
  static List<NotificationItem> filterByType(
    List<NotificationItem> notifications,
    String filter,
  ) {
    switch (filter) {
      case 'Unread':
        return notifications.where((n) => !n.isRead).toList();
      case 'Appointment':
        return notifications
            .where((n) => n.type == NotificationType.appointment)
            .toList();
      case 'Health':
        return notifications
            .where((n) => n.type == NotificationType.health)
            .toList();
      case 'Payment':
        return notifications
            .where((n) => n.type == NotificationType.payment)
            .toList();
      default:
        return notifications;
    }
  }

  // Get unread notifications count
  static int getUnreadCount(List<NotificationItem> notifications) {
    return notifications.where((n) => !n.isRead).length;
  }

  // Sort notifications by date (newest first)
  static List<NotificationItem> sortByDate(
    List<NotificationItem> notifications,
  ) {
    final sortedNotifications = List<NotificationItem>.from(notifications);
    sortedNotifications.sort(
      (a, b) => b.dateTimeSent.compareTo(a.dateTimeSent),
    );
    return sortedNotifications;
  }

  // Format timestamp for display
  static String formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day.toString().padLeft(2, '0')}/${timestamp.month.toString().padLeft(2, '0')}/${timestamp.year}';
    }
  }

  // Get notification color based on type
  static Color getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.appointment:
        return const Color.fromARGB(255, 90, 183, 226);
      case NotificationType.health:
        return Colors.green;
      case NotificationType.payment:
        return Colors.orange;
      case NotificationType.service:
        return Colors.purple;
    }
  }

  // Get notification icon based on type
  static IconData getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.appointment:
        return Icons.calendar_today;
      case NotificationType.health:
        return Icons.favorite;
      case NotificationType.payment:
        return Icons.payment;
      case NotificationType.service:
        return Icons.local_hospital;
    }
  }

  // Search notifications by text
  static List<NotificationItem> searchNotifications(
    List<NotificationItem> notifications,
    String searchTerm,
  ) {
    if (searchTerm.isEmpty) return notifications;

    final lowerSearchTerm = searchTerm.toLowerCase();

    return notifications.where((notification) {
      return notification.title.toLowerCase().contains(lowerSearchTerm) ||
          notification.message.toLowerCase().contains(lowerSearchTerm);
    }).toList();
  }

  // Get notifications by date range
  static List<NotificationItem> filterByDateRange(
    List<NotificationItem> notifications,
    DateTime startDate,
    DateTime endDate,
  ) {
    return notifications.where((notification) {
      return notification.dateTimeSent.isAfter(
            startDate.subtract(const Duration(days: 1)),
          ) &&
          notification.dateTimeSent.isBefore(
            endDate.add(const Duration(days: 1)),
          );
    }).toList();
  }
}
