import 'package:flutter/material.dart';
import '../models/notification.dart';
import '../services/notification_service.dart';

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
      final notifications = await NotificationService.getNotifications();

      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });

      print('Loaded ${_notifications.length} notifications');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load notifications: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotifications = NotificationService.filterByType(
      _notifications,
      _selectedFilter,
    );

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
            IconButton(
              onPressed: _markAllAsRead,
              icon: Icon(
                Icons.done_all,
                color: const Color.fromARGB(255, 90, 183, 226),
              ),
              tooltip: 'Mark all as read',
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

  Widget _buildEmptyState() {
    return const SizedBox.shrink();
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
                  color: NotificationService.getNotificationColor(
                    notification.type,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  NotificationService.getNotificationIcon(notification.type),
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
                          NotificationService.formatTimestamp(
                            notification.timestamp,
                          ),
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
                          if (notification.type ==
                              NotificationType.appointment) ...[
                            const Spacer(),
                            TextButton(
                              onPressed: () => _cancelAppointment(notification),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                minimumSize: Size.zero,
                              ),
                              child: Text(
                                'Cancel appointment',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
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

  Future<void> _markAsRead(NotificationItem notification) async {
    try {
      print('Marking notification ${notification.notificationId} as read');
      print(
        'Notification details: ${notification.notificationId}, ${notification.message}',
      );

      await NotificationService.markAsRead(notification.notificationId);

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
      final unreadIds = unreadNotifications
          .map((n) => n.notificationId)
          .toList();
      await NotificationService.markMultipleAsRead(unreadIds);

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

  Future<void> _cancelAppointment(NotificationItem notification) async {
    // Show confirmation dialog
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Cancel Appointment'),
          content: Text(
            'Are you sure you want to cancel the appointment?\n\n${notification.message}',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Yes, Cancel'),
            ),
          ],
        );
      },
    );

    if (shouldCancel != true) {
      return;
    }

    try {
      // Extract appointment ID from notification message
      final appointmentId = NotificationService.extractAppointmentIdFromMessage(
        notification.message,
      );

      if (appointmentId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not find appointment ID in notification'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      print('Cancelling appointment ID: $appointmentId');

      await NotificationService.cancelAppointment(appointmentId);

      // Mark the notification as read after successful cancellation
      await _markAsRead(notification);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Appointment cancelled successfully'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error cancelling appointment: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel appointment: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
