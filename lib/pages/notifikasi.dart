import 'package:flutter/material.dart';

class NotifikasiPage extends StatefulWidget {
  const NotifikasiPage({super.key});

  @override
  State<NotifikasiPage> createState() => _NotifikasiPageState();
}

class _NotifikasiPageState extends State<NotifikasiPage> {
  final List<Map<String, dynamic>> _notifications = [
    {
      'title': 'Jadwal Latihan Berubah',
      'message': 'Jadwal latihan hari ini diubah menjadi pukul 15:00',
      'time': '2 jam yang lalu',
      'isRead': false,
      'type': 'schedule'
    },
    {
      'title': 'Penilaian Baru',
      'message': 'Anda mendapat penilaian baru dari Coach Ahmad',
      'time': '5 jam yang lalu',
      'isRead': true,
      'type': 'assessment'
    },
    {
      'title': 'Pengumuman',
      'message': 'Akan ada turnamen minggu depan, harap mempersiapkan diri',
      'time': '1 hari yang lalu',
      'isRead': true,
      'type': 'announcement'
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notifikasi',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _notifications.length,
        itemBuilder: (context, index) =>
            _buildNotificationCard(_notifications[index]),
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05)
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _getNotificationColor(notification['type']),
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getNotificationIcon(notification['type']),
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notification['title'],
                  style: TextStyle(
                    color: Colors.grey[100],
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  notification['message'],
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  notification['time'],
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                notification['isRead'] ? 'Read' : 'Unread',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Color> _getNotificationColor(String type) {
    switch (type) {
      case 'schedule':
        return [Colors.blue.shade400, Colors.blue.shade700];
      case 'assessment':
        return [Colors.orange.shade400, Colors.orange.shade700];
      case 'announcement':
        return [Colors.purple.shade400, Colors.purple.shade700];
      default:
        return [Colors.green.shade400, Colors.green.shade700];
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'schedule':
        return Icons.event_note;
      case 'assessment':
        return Icons.assessment;
      case 'announcement':
        return Icons.campaign;
      default:
        return Icons.notifications;
    }
  }
}
