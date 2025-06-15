import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../services/media_service.dart';

class VideoPlayerItem extends StatefulWidget {
  final String id;
  final String url;
  final bool? isFullscreen;
  final VoidCallback onDeleted;

  const VideoPlayerItem({
    super.key,
    required this.id,
    required this.url,
    this.isFullscreen,
    required this.onDeleted,
  });

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem> {
  late VideoPlayerController _controller;
  ChewieController? _chewieController;
  final _mediaService = MediaService();

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    _controller = VideoPlayerController.file(File(widget.url));
    await _controller.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _controller,
      autoPlay: false,
      looping: false,
      additionalOptions: (context) {
        return [
          OptionItem(
            onTap: (context) => _downloadMedia(),
            iconData: Icons.download,
            title: 'Download',
          ),
          OptionItem(
            onTap: (context) => _removeMedia(),
            iconData: Icons.delete,
            title: 'Delete',
          ),
        ];
      },
    );

    setState(() {});
  }

  void _downloadMedia() async {
    final message = await _mediaService.downloadMedia(
      url: widget.url,
      isImage: false,
    );
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _removeMedia() async {
    Navigator.pop(context);
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
              Navigator.pop(context);
              final message = await _mediaService.deleteMedia(
                url: widget.url,
                projectId: widget.id,
                isImage: false,
              );
              if (mounted) {
                widget.onDeleted();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(message)));
              }
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

  @override
  void dispose() {
    _controller.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _chewieController != null &&
            _chewieController!.videoPlayerController.value.isInitialized
        ? Chewie(controller: _chewieController!)
        : Center(child: CircularProgressIndicator());
  }
}
