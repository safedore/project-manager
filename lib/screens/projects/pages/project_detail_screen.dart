import 'package:flutter/material.dart';
import '../../../models/project_model.dart';
import 'media_images.dart';
import 'media_videos.dart';

class ProjectDetailScreen extends StatefulWidget {
  final ProjectModel project;
  const ProjectDetailScreen({super.key, required this.project});

  @override
  State<ProjectDetailScreen> createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen>
    with SingleTickerProviderStateMixin {

  @override
  void initState() {
    super.initState();
    _setPages();
  }

  List<Widget>_tabPages = [];

  _setPages() {
    _tabPages = [
      MediaImagesScreen(project: widget.project),
      MediaVideosScreen(project: widget.project),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.project.name)),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              tabs: [
                Tab(child: Text('Images')),
                Tab(child: Text('Videos')),
              ],
            ),
            // const SizedBox(height: 20),
            Expanded(
              child: TabBarView(
                children: [
                  _tabPages[0],
                  _tabPages[1],
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
