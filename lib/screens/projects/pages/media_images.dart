import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:project_manager/screens/projects/widgets/image_item.dart';
import '../../../models/project_model.dart';
import '../../../services/media_service.dart';

class MediaImagesScreen extends StatefulWidget {
  final ProjectModel project;
  const MediaImagesScreen({super.key, required this.project});

  @override
  State<MediaImagesScreen> createState() => _MediaImagesScreenState();
}

class _MediaImagesScreenState extends State<MediaImagesScreen> {
  final _mediaService = MediaService();

  Future<List<String>> _fetchImages() async {
    final doc = await FirebaseFirestore.instance
        .collection('projects')
        .doc(widget.project.id)
        .get();

    if (doc.exists) {
      final project = ProjectModel.fromMap(doc.id, doc.data()!);
      return project.imageUrls;
    }
    return [];
  }

  Future<void> _uploadImage() async {
    await _mediaService.uploadMedia(
      projectId: widget.project.id,
      isImage: true,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _uploadImage,
        child: const Icon(Icons.upload),
      ),
      body: FutureBuilder<List<String>>(
        future: _fetchImages(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final imageUrls = snapshot.data ?? [];

          if (imageUrls.isEmpty) {
            return const Center(child: Text("No Images"));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: imageUrls.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  showGeneralDialog(
                    context: context,
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        ImageItem(
                          imageUrls: imageUrls,
                          initialIndex: index,
                          id: widget.project.id,
                          onDeleted: () => setState(() {}),
                        ),
                  );
                },
                child: Hero(
                  tag: imageUrls[index],
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      errorBuilder: (context, error, stackTrace) => GestureDetector(
                        onTap: () => _removeMedia(imageUrls[index]),
                        child: SvgPicture.asset(
                          'assets/broken_imagesvg.svg',
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                      File(imageUrls[index]),
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          );
        },
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
              Navigator.pop(mContext);
              await _mediaService.deleteMedia(
                url: url,
                projectId: widget.project.id,
                isImage: true,
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
