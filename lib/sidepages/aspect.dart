import 'package:flutter/material.dart';

class AspectPage extends StatefulWidget {
  const AspectPage({super.key});

  @override
  State<AspectPage> createState() => _AspectPageState();
}

class _AspectPageState extends State<AspectPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, dynamic>> _aspects = [
    {
      'name': 'Technical Skills',
      'description': 'Ball control, passing, shooting accuracy',
      'status': 'Active',
      'lastUpdated': '10-15',
      'totalStudents': 45,
      'progress': 0.75,
      'color': Colors.blue
    },
    {
      'name': 'Physical Fitness',
      'description': 'Stamina, strength, speed',
      'status': 'Active',
      'lastUpdated': '10-14',
      'totalStudents': 38,
      'progress': 0.60,
      'color': Colors.green
    },
    {
      'name': 'Tactical Understanding',
      'description': 'Game awareness, positioning, decision making',
      'status': 'Inactive',
      'lastUpdated': '10-10',
      'totalStudents': 32,
      'progress': 0.45,
      'color': Colors.orange
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
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Aspects',
          style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics, color: Colors.white, size: 20),
            onPressed: () {
              // TODO: Show analytics
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white, size: 20),
            onPressed: () {
              // TODO: Show filters
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Container(
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        color: Colors.white.withOpacity(0.1), width: 1))),
            child: TabBar(
              controller: _tabController,
              tabs: [
                Tab(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(3)),
                    ),
                    const SizedBox(width: 6),
                    const Text('Active', style: TextStyle(fontSize: 12))
                  ],
                )),
                Tab(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(3)),
                    ),
                    const SizedBox(width: 6),
                    const Text('Inactive', style: TextStyle(fontSize: 12))
                  ],
                )),
              ],
              indicatorColor: Colors.green,
              indicatorWeight: 2,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12))),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: TextField(
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'Search aspects...',
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
                      // TODO: Implement aspect dialog
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
                _buildAspectList(true),
                _buildAspectList(false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAspectList(bool isActive) {
    final filteredAspects = _aspects
        .where((aspect) =>
            aspect['status'] == (isActive ? 'Active' : 'Inactive') &&
            aspect['name'].toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: filteredAspects.length,
      itemBuilder: (context, index) {
        final aspect = filteredAspects[index];
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
                      (aspect['color'] ?? Colors.grey).withOpacity(0.2),
                  child: Icon(Icons.category,
                      color: aspect['color'] ?? Colors.grey, size: 16),
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        aspect['name'],
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
                        aspect['status'],
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
                      aspect['description'],
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          Icon(Icons.people,
                              size: 14, color: Colors.white.withOpacity(0.7)),
                          const SizedBox(width: 4),
                          Text(
                            '${aspect['totalStudents']} students',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.update,
                              size: 14, color: Colors.white.withOpacity(0.7)),
                          const SizedBox(width: 4),
                          Text(
                            '${aspect['lastUpdated']}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                trailing: PopupMenuButton(
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.white.withOpacity(0.7),
                    size: 18,
                  ),
                  color: const Color(0xFF1E1E1E),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: ListTile(
                        leading: const Icon(Icons.edit,
                            color: Colors.white, size: 18),
                        title: const Text(
                          'Edit',
                          style: TextStyle(color: Colors.white, fontSize: 13),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Edit Aspect',
                                  style: TextStyle(fontSize: 16)),
                              content: TextField(
                                controller: TextEditingController(
                                    text: aspect['description']),
                                decoration: const InputDecoration(
                                  labelText: 'Description',
                                  labelStyle: TextStyle(fontSize: 13),
                                ),
                                style: const TextStyle(fontSize: 13),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel',
                                      style: TextStyle(fontSize: 13)),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // TODO: Save changes
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Save',
                                      style: TextStyle(fontSize: 13)),
                                ),
                              ],
                            ),
                          );
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
                          isActive ? 'Deactivate' : 'Activate',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13),
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          setState(() {
                            aspect['status'] = isActive ? 'Inactive' : 'Active';
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
                      'Progress',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: aspect['progress'],
                        backgroundColor: Colors.white.withOpacity(0.1),
                        valueColor:
                            AlwaysStoppedAnimation<Color>(aspect['color']),
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

  // ... rest of the code remains the same ...
}
