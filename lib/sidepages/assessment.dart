import 'package:flutter/material.dart';

class AssessmentsidePage extends StatefulWidget {
  const AssessmentsidePage({super.key});

  @override
  State<AssessmentsidePage> createState() => _AssessmentIsidePageState();
}

class _AssessmentIsidePageState extends State<AssessmentsidePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  final List<Map<String, dynamic>> _assessments = [
    {
      'name': 'Teknik Dasar',
      'description': 'Evaluasi kemampuan teknik dasar pemain',
      'status': 'Active',
      'totalStudents': 24,
      'progress': 0.75,
      'color': Colors.blue
    },
    {
      'name': 'Kebugaran Fisik',
      'description': 'Penilaian kondisi fisik dan stamina',
      'status': 'Active',
      'totalStudents': 18,
      'progress': 0.6,
      'color': Colors.orange
    },
    {
      'name': 'Pemahaman Taktik',
      'description': 'Evaluasi kesadaran permainan dan pengambilan keputusan',
      'status': 'Inactive',
      'totalStudents': 12,
      'progress': 0.3,
      'color': Colors.purple
    }
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.5),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Penilaian',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Aktif'),
            Tab(text: 'Nonaktif'),
          ],
          labelStyle:
              const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          unselectedLabelStyle: const TextStyle(fontSize: 13),
          indicatorSize: TabBarIndicatorSize.label,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: TextField(
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'Search assessments...',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 13,
                        ),
                        border: InputBorder.none,
                        icon: Icon(
                          Icons.search,
                          color: Colors.white.withOpacity(0.4),
                          size: 18,
                        ),
                      ),
                      onChanged: (value) =>
                          setState(() => _searchQuery = value),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade600, Colors.green.shade400],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implement assessment dialog
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    icon: const Icon(Icons.add, color: Colors.white, size: 16),
                    label: const Text(
                      'Tambah',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAssessmentList(true),
                _buildAssessmentList(false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssessmentList(bool isActive) {
    final filteredAssessments = _assessments
        .where((assessment) =>
            assessment['status'] == (isActive ? 'Active' : 'Inactive') &&
            assessment['name']
                .toLowerCase()
                .contains(_searchQuery.toLowerCase()))
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: filteredAssessments.length,
      itemBuilder: (context, index) {
        final assessment = filteredAssessments[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: CircleAvatar(
                  radius: 16,
                  backgroundColor:
                      (assessment['color'] ?? Colors.grey).withOpacity(0.2),
                  child: Icon(Icons.assessment,
                      color: assessment['color'] ?? Colors.grey, size: 16),
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        assessment['name'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.green.withOpacity(0.2)
                            : Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        assessment['status'],
                        style: TextStyle(
                          color: isActive ? Colors.green : Colors.grey,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    Text(
                      assessment['description'],
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.people,
                            size: 14, color: Colors.white.withOpacity(0.7)),
                        const SizedBox(width: 4),
                        Text(
                          '${assessment['totalStudents']} siswa',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: PopupMenuButton(
                  icon: Icon(Icons.more_vert,
                      color: Colors.white.withOpacity(0.7), size: 20),
                  color: Colors.grey[900],
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: ListTile(
                        leading: const Icon(Icons.edit,
                            color: Colors.white, size: 18),
                        title: const Text(
                          'Ubah',
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          // TODO: Implement edit functionality
                        },
                      ),
                    ),
                    PopupMenuItem(
                      child: ListTile(
                        leading: Icon(
                          isActive ? Icons.clear : Icons.check,
                          color: Colors.white,
                          size: 18,
                        ),
                        title: Text(
                          isActive ? 'Nonaktifkan' : 'Aktifkan',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          setState(() {
                            assessment['status'] =
                                isActive ? 'Inactive' : 'Active';
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Progres',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: assessment['progress'],
                        backgroundColor: Colors.white.withOpacity(0.1),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(assessment['color']),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
