import 'package:flutter/material.dart';
import '../utils/authorization.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<NotificationItem> _notifications = [];
  String _selectedFilter = 'All';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (Authorization.userId == null) {
        throw Exception('User ID not found');
      }

      final response = await http.get(
        Uri.parse(
          'http://10.0.2.2:5081/Notification/user/${Authorization.userId}/unread',
        ),
        headers: {
          'Authorization': 'Bearer ${Authorization.token}',
          'Content-Type': 'application/json',
        },
      );

      print(
        'Notifications API Response: ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);

        setState(() {
          _notifications = responseData.map((notification) {
            return NotificationItem.fromJson(notification);
          }).toList();
        });

        print('Loaded ${_notifications.length} notifications');
      } else {
        throw Exception(
          'Failed to load notifications: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load notifications: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotifications = _getFilteredNotifications();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey[800],
        elevation: 0,
        title: const Text(
          "Notifications",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        actions: [
          // Refresh button
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.grey[600]),
            onPressed: _loadNotifications,
          ),
          // Mark all as read button
          if (_notifications.any((n) => !n.isRead))
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                'Mark all read',
                style: TextStyle(
                  color: const Color.fromARGB(255, 90, 183, 226),
                  fontSize: 14,
                ),
              ),
            ),
          // Filter button
          PopupMenuButton<String>(
            onSelected: (String value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(value: 'All', child: Text('All')),
              const PopupMenuItem<String>(
                value: 'Unread',
                child: Text('Unread'),
              ),
              const PopupMenuItem<String>(
                value: 'Appointment',
                child: Text('Appointments'),
              ),
              const PopupMenuItem<String>(
                value: 'Health',
                child: Text('Health'),
              ),
              const PopupMenuItem<String>(
                value: 'Payment',
                child: Text('Payments'),
              ),
            ],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Icon(Icons.filter_list, color: Colors.grey[600]),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Color.fromARGB(255, 90, 183, 226),
                ),
              ),
            )
          : Column(
              children: [
                // Filter indicator
                if (_selectedFilter != 'All')
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    color: Colors.grey[100],
                    child: Row(
                      children: [
                        Icon(
                          Icons.filter_list,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Showing: $_selectedFilter',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedFilter = 'All';
                            });
                          },
                          child: Text(
                            'Clear',
                            style: TextStyle(
                              color: const Color.fromARGB(255, 90, 183, 226),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Notifications list
                Expanded(
                  child: filteredNotifications.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredNotifications.length,
                          itemBuilder: (context, index) {
                            final notification = filteredNotifications[index];
                            return _buildNotificationCard(notification);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  List<NotificationItem> _getFilteredNotifications() {
    switch (_selectedFilter) {
      case 'Unread':
        return _notifications.where((n) => !n.isRead).toList();
      case 'Appointment':
        return _notifications
            .where((n) => n.type == NotificationType.appointment)
            .toList();
      case 'Health':
        return _notifications
            .where((n) => n.type == NotificationType.health)
            .toList();
      case 'Payment':
        return _notifications
            .where((n) => n.type == NotificationType.payment)
            .toList();
      default:
        return _notifications;
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No notifications found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem notification) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: notification.isRead ? 1 : 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: notification.isRead ? Colors.white : Colors.blue[50],
      child: InkWell(
        onTap: () => _markAsRead(notification),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notification icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getNotificationColor(notification.type),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  _getNotificationIcon(notification.type),
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),

              // Notification content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and timestamp
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: notification.isRead
                                  ? FontWeight.w500
                                  : FontWeight.w600,
                              color: notification.isRead
                                  ? Colors.grey[700]
                                  : Colors.black,
                            ),
                          ),
                        ),
                        Text(
                          _formatTimestamp(notification.timestamp),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Message
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.3,
                      ),
                    ),

                    // Action buttons
                    if (!notification.isRead) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () => _markAsRead(notification),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              minimumSize: Size.zero,
                            ),
                            child: Text(
                              'Mark as read',
                              style: TextStyle(
                                color: const Color.fromARGB(255, 90, 183, 226),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Unread indicator
              if (!notification.isRead)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 90, 183, 226),
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getNotificationColor(NotificationType type) {
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

  IconData _getNotificationIcon(NotificationType type) {
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

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.month}/${timestamp.day}/${timestamp.year}';
    }
  }

  Future<void> _markAsRead(NotificationItem notification) async {
    try {
      print('Marking notification ${notification.notificationId} as read');
      print(
        'Notification details: ${notification.notificationId}, ${notification.message}',
      );

      final response = await http.put(
        Uri.parse(
          'http://10.0.2.2:5081/Notification/${notification.notificationId}/mark-as-read',
        ),
        headers: {
          'Authorization': 'Bearer ${Authorization.token}',
          'Content-Type': 'application/json',
        },
      );

      print(
        'Mark as read API Response: ${response.statusCode} - ${response.body}',
      );

      // Accept both 200 and 204 as success responses
      if (response.statusCode == 200 || response.statusCode == 204) {
        setState(() {
          final index = _notifications.indexWhere(
            (n) => n.notificationId == notification.notificationId,
          );
          if (index != -1) {
            _notifications[index] = NotificationItem(
              notificationId: notification.notificationId,
              userId: notification.userId,
              message: notification.message,
              dateTimeSent: notification.dateTimeSent,
              isRead: true,
            );
            print('Updated notification at index $index to read status');
          } else {
            print(
              'Notification not found in list for ID: ${notification.notificationId}',
            );
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Marked "${notification.title}" as read'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
          ),
        );
      } else {
        throw Exception(
          'Failed to mark notification as read: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('Error marking notification as read: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to mark notification as read: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      // Get all unread notifications
      final unreadNotifications = _notifications
          .where((n) => !n.isRead)
          .toList();

      if (unreadNotifications.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No unread notifications to mark'),
            backgroundColor: Colors.blue,
            duration: const Duration(seconds: 1),
          ),
        );
        return;
      }

      // Mark each unread notification as read via API
      for (final notification in unreadNotifications) {
        final response = await http.put(
          Uri.parse(
            'http://10.0.2.2:5081/Notification/${notification.notificationId}/mark-as-read',
          ),
          headers: {
            'Authorization': 'Bearer ${Authorization.token}',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode != 200 && response.statusCode != 204) {
          throw Exception(
            'Failed to mark notification ${notification.notificationId} as read: ${response.statusCode}',
          );
        }
      }

      // Update UI state
      setState(() {
        for (int i = 0; i < _notifications.length; i++) {
          if (!_notifications[i].isRead) {
            _notifications[i] = NotificationItem(
              notificationId: _notifications[i].notificationId,
              userId: _notifications[i].userId,
              message: _notifications[i].message,
              dateTimeSent: _notifications[i].dateTimeSent,
              isRead: true,
            );
          }
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Marked ${unreadNotifications.length} notifications as read',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to mark all notifications as read: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}

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

  // Helper getters for backward compatibility
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

enum NotificationType { appointment, health, payment, service }
