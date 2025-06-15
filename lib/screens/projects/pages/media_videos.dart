import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:project_manager/screens/projects/widgets/video_player_item.dart';
import '../../../models/project_model.dart';
import '../../../services/media_service.dart';

class MediaVideosScreen extends StatefulWidget {
  final ProjectModel project;
  const MediaVideosScreen({super.key, required this.project});

  @override
  State<MediaVideosScreen> createState() => _MediaVideosScreenState();
}

class _MediaVideosScreenState extends State<MediaVideosScreen> {
  final _mediaService = MediaService();

  Future<List<String>> _fetchVideos() async {
    final doc = await FirebaseFirestore.instance
        .collection('projects')
        .doc(widget.project.id)
        .get();

    if (doc.exists) {
      final project = ProjectModel.fromMap(doc.id, doc.data()!);
      return project.videoUrls;
    }
    return [];
  }

  Future<void> _uploadVideo() async {
    await _mediaService.uploadMedia(
      projectId: widget.project.id,
      isImage: false,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: _uploadVideo,
          child: const Icon(Icons.upload),
        ),
        body: FutureBuilder<List<String>>(
          future: _fetchVideos(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final videoUrls = snapshot.data ?? [];

            if (videoUrls.isEmpty) {
              return const Center(child: Text("No Videos"));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: videoUrls.length,
              itemBuilder: (context, index) {
                final exists = File(videoUrls[index]).existsSync();
                return Container(
                  height: 250,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(color: Colors.grey),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  child: !exists ? GestureDetector(
                    onTap: () => _removeMedia(videoUrls[index]),
                    child: SvgPicture.asset(
                      'assets/broken_imagesvg.svg',
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ) : VideoPlayerItem(
                    url: (videoUrls[index]),
                    id: widget.project.id,
                    onDeleted: () => setState(() {}),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _removeMedia(url) {
    showDialog(
      context: context,
      builder: (mContext) => AlertDialog(
        title: const Text(
          'Confirm Deletion',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to delete this media? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(mContext);
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              print('$url as da das sa as  sa');
              Navigator.pop(mContext);
              await _mediaService.deleteMedia(
                url: url,
                projectId: widget.project.id,
                isImage: false,
              );
              if (!mounted) return;
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.withValues(alpha: 0.7),
            ),
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

}
