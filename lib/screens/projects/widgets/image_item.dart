import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:project_manager/services/media_service.dart';

class ImageItem extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;
  final String id;
  final VoidCallback onDeleted;

  const ImageItem({
    super.key,
    required this.imageUrls,
    required this.initialIndex,
    required this.id,
    required this.onDeleted,
  });
  @override
  State<ImageItem> createState() => _ImageItemState();
}

class _ImageItemState extends State<ImageItem> {
  final _mediaService = MediaService();
  final ValueNotifier _tapped = ValueNotifier(false);
  final ValueNotifier _selectedIndex = ValueNotifier(null);
  double _verticalDrag = 0;
  final double _dismissThreshold = 150;
  late final PageController _pageController;

  int? initialIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex.value = widget.initialIndex;
    initialIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    setState(() {
      _verticalDrag += details.delta.dy;
      if (_tapped.value) {
        _tapped.value = false;
      }
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (_verticalDrag.abs() > _dismissThreshold) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _verticalDrag = 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double scale = 1 - (_verticalDrag.abs() / 1000).clamp(0.0, 0.2);
    return ValueListenableBuilder(
      valueListenable: _tapped,
      builder: (context, tValue, child) {
        return ValueListenableBuilder(
          valueListenable: _selectedIndex,
          builder: (context, value, child) {
            return Stack(
              children: [
                GestureDetector(
                  onVerticalDragUpdate: _onVerticalDragUpdate,
                  onVerticalDragEnd: _onVerticalDragEnd,
                  child: Center(
                    child: Transform.translate(
                      offset: Offset(0, _verticalDrag),
                      child: Transform.scale(
                        scale: scale,
                        child: PhotoViewGallery.builder(
                          pageController: _pageController,
                          onPageChanged: (index) {
                            _selectedIndex.value = index;
                          },
                          itemCount: widget.imageUrls.length,
                          builder: (BuildContext context, int index) {
                            return PhotoViewGalleryPageOptions(
                              imageProvider: FileImage(
                                File(widget.imageUrls[index]),
                              ),
                              errorBuilder: (context, error, stackTrace) => Text("Couldn't load Image"),
                              initialScale:
                                  PhotoViewComputedScale.contained * 0.8,
                              heroAttributes: PhotoViewHeroAttributes(
                                tag: widget.imageUrls[initialIndex ?? 0],
                              ),
                              minScale: PhotoViewComputedScale.contained,
                              maxScale: PhotoViewComputedScale.covered * 2,
                              onTapDown: (context, details, controllerValue) {
                                _tapped.value = !_tapped.value;
                              },
                            );
                          },
                          backgroundDecoration: const BoxDecoration(
                            color: Colors.transparent,
                          ),
                          loadingBuilder: (context, event) => Center(
                            child: SizedBox(
                              width: 20.0,
                              height: 20.0,
                              child: CircularProgressIndicator(
                                value: event == null
                                    ? 0
                                    : event.cumulativeBytesLoaded /
                                          (event.expectedTotalBytes != null
                                              ? event.expectedTotalBytes!
                                              : 1.0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (tValue)
                  SizedBox(
                    height: 80,
                    child: AppBar(
                      backgroundColor: Colors.black.withValues(alpha: 0.5),
                      iconTheme: IconThemeData(color: Colors.white),
                      actions: [
                        IconButton(
                          onPressed: () => _downloadMedia(
                            widget.imageUrls[_selectedIndex.value],
                          ),
                          icon: Icon(Icons.download),
                        ),
                        IconButton(
                          onPressed: () => _removeMedia(
                            widget.imageUrls[_selectedIndex.value],
                          ),
                          icon: Icon(Icons.delete),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  void _downloadMedia(url) async {
    final message = await _mediaService.downloadMedia(url: url, isImage: true);
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
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
              final index = _selectedIndex.value ?? 0;
              await _mediaService.deleteMedia(
                url: url,
                projectId: widget.id,
                isImage: true,
              );
              if (!mounted) return;
              setState(() {
                widget.imageUrls.removeAt(index);
                if (widget.imageUrls.isEmpty) {
                  Navigator.pop(context);
                } else {
                  _selectedIndex.value = index > 0 ? index - 1 : 0;
                  initialIndex = index > 0 ? index - 1 : 0;
                  _pageController.jumpToPage(_selectedIndex.value);
                }
              });
              widget.onDeleted();
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
