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
        itemBuilder: (context, index) => _buildNotificationCard(_notifications[index]),
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: notification['isRead'] 
          ? Colors.white.withOpacity(0.05)
          : Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification['isRead']
            ? Colors.white.withOpacity(0.1)
            : Colors.green.withOpacity(0.3),
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getNotificationIcon(notification['type']),
            color: Colors.green,
            size: 20,
          ),
        ),
        title: Text(
          notification['title'],
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: notification['isRead'] ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification['message'],
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              notification['time'],
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 11,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            color: Colors.white.withOpacity(0.7),
            size: 20,
          ),
          color: const Color(0xFF1A1A1A),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'mark',
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text('Tandai dibaca', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, color: Colors.red, size: 18),
                  SizedBox(width: 8),
                  Text('Hapus', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
