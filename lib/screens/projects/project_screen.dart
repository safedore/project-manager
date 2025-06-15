import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../models/project_model.dart';
import 'pages/project_detail_screen.dart';

class ProjectScreen extends StatefulWidget {
  const ProjectScreen({super.key});

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen>
    with SingleTickerProviderStateMixin {
  List<ProjectModel> _projects = [];
  List<ProjectModel> _filteredProjects = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProjects();
    _searchController.addListener(_onSearch);
  }

  void _onSearch() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProjects = _projects
          .where((p) => p.name.toLowerCase().contains(query))
          .toList();
    });
  }

  Future<void> _fetchProjects() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('projects')
        .get();
    final projects = snapshot.docs
        .map((doc) => ProjectModel.fromMap(doc.id, doc.data()))
        .toList();
    if (mounted) {
      setState(() {
        _projects = projects;
        _filteredProjects = projects;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search Projects...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredProjects.length,
              itemBuilder: (context, index) {
                final project = _filteredProjects[index];
                return ListTile(
                  title: Text(project.name),
                  subtitle: Text(
                    'Lat: ${project.latitude}, Lng: ${project.longitude}',
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProjectDetailScreen(project: project),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
