// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:video_player/video_player.dart';
//
// import '../../../services/media_service.dart';
//
// class VideoPlayerItem extends StatefulWidget {
//   final String id;
//   final String url;
//   final bool? isFullscreen;
//
//   const VideoPlayerItem({
//     super.key,
//     required this.id,
//     required this.url,
//     this.isFullscreen,
//   });
//
//   @override
//   State<VideoPlayerItem> createState() => _VideoPlayerItemState();
// }
//
// class _VideoPlayerItemState extends State<VideoPlayerItem> {
//   late VideoPlayerController _controller;
//   late VideoPlayerController _fullController;
//   late Future<void> _initializeVideoPlayerFuture;
//   Duration _currentPosition = Duration.zero;
//   final _mediaService = MediaService();
//   final String _mediaPath = '';
//
//   @override
//   void initState() {
//     super.initState();
//     _checkMedia();
//     _controller = VideoPlayerController.file(File(widget.url));
//     _initializeVideoPlayerFuture = _controller.initialize().then((_) {
//       setState(() {});
//       _controller.addListener(_updatePosition);
//     });
//
//     _fullController = VideoPlayerController.file(File(widget.url));
//     _fullController.initialize().then((_) {
//       setState(() {});
//       _fullController.addListener(_updatePosition);
//     });
//   }
//
//   void _updatePosition() {
//     final controller = widget.isFullscreen == true
//         ? _fullController
//         : _controller;
//     if (mounted) {
//       setState(() {
//         _currentPosition = controller.value.position;
//       });
//     }
//   }
//
//   void _checkMedia() async {
//     // _mediaPath = await _mediaService.checkDownloadedMedia(url: widget.url);
//   }
//
//   @override
//   void dispose() {
//     _controller.removeListener(_updatePosition);
//     _fullController.removeListener(_updatePosition);
//     _controller.dispose();
//     _fullController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final orientation = MediaQuery.of(context).orientation;
//     final size = (widget.isFullscreen == true ? _fullController : _controller)
//         .value
//         .size;
//     final videoRotation =
//         (widget.isFullscreen == true ? _fullController : _controller)
//             .value
//             .rotationCorrection;
//     final isPlaying =
//         (widget.isFullscreen == true ? _fullController : _controller)
//             .value
//             .isPlaying;
//     final duration =
//         (widget.isFullscreen == true ? _fullController : _controller)
//             .value
//             .duration;
//     return FutureBuilder(
//       future: _initializeVideoPlayerFuture,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.done) {
//           return Column(
//             children: [
//               GestureDetector(
//                 onTap: () {
//                   if (isPlaying) {
//                     _pauseVideo();
//                   } else {
//                     _playVideo();
//                   }
//                 },
//                 child: widget.isFullscreen == true
//                     ? orientation == Orientation.landscape ? Stack(
//                         children: [
//                           SizedBox(
//                             height: MediaQuery.of(context).size.height,
//                             child: VideoPlayer(_fullController),
//                           ),
//                           Positioned(
//                             // bottom: 1,
//                               child: _controls(duration, isPlaying, videoRotation, orientation)),
//                         ],
//                       ) :
//                       AspectRatio(
//                       aspectRatio:
//                           _fullController.value.aspectRatio * 1,
//                       child: VideoPlayer(_fullController),
//                     )
//                     : SizedBox(
//                         width: size.width > 300 ? size.width / 2.5 : size.width,
//                         height: size.height > 300
//                             ? size.height / 2.5
//                             : size.height,
//                         child: VideoPlayer(
//                           widget.isFullscreen == true
//                               ? _fullController
//                               : _controller,
//                         ),
//                       ),
//               ),
//               if (orientation == Orientation.portrait || widget.isFullscreen != true) ...[
//                 _controls(duration, isPlaying, videoRotation, orientation),
//               ],
//             ],
//           );
//         } else {
//           return const Center(child: CircularProgressIndicator());
//         }
//       },
//     );
//   }
//
//   Widget _controls(duration, isPlaying, videoRotation, orientation) {
//     return SizedBox(
//       height: 116,
//       child: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Row(
//               children: [
//                 _textDuration(_currentPosition),
//                 Expanded(
//                   child: VideoProgressIndicator(
//                     widget.isFullscreen == true ? _fullController : _controller,
//                     allowScrubbing: true,
//                     padding: const EdgeInsets.all(8),
//                     colors: VideoProgressColors(
//                       playedColor: Colors.blue,
//                       bufferedColor: Colors.blue.withValues(alpha: 0.3),
//                       backgroundColor: widget.isFullscreen == true
//                           ? Colors.white
//                           : Color.fromRGBO(200, 200, 200, 0.5),
//                     ),
//                   ),
//                 ),
//                 _textDuration(duration),
//               ],
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 _icons(_playVideo, Icons.play_arrow, isPlaying),
//                 _icons(
//                   _pauseVideo,
//                   Icons.pause,
//                   !isPlaying && _currentPosition.inSeconds != 0,
//                 ),
//                 _icons(
//                   _stopVideo,
//                   Icons.stop,
//                   !isPlaying && _currentPosition.inSeconds == 0,
//                 ),
//                 _icons(
//                   _downloadFile,
//                   _mediaPath.isEmpty ? Icons.download : Icons.download_done,
//                   _mediaPath.isNotEmpty,
//                 ),
//                 _icons(
//                   () => _fullscreenVideo(videoRotation, orientation),
//                   widget.isFullscreen == true
//                       ? Icons.fullscreen_exit
//                       : Icons.fullscreen,
//                   null,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _icons(callback, icon, isSelected) {
//     return Container(
//       decoration: BoxDecoration(
//         color: isSelected == true ? Colors.blue.shade100 : Colors.grey.shade100,
//         borderRadius: BorderRadius.all(Radius.circular(16)),
//       ),
//       child: IconButton(
//         onPressed: callback,
//         icon: Icon(
//           icon,
//           color: widget.isFullscreen == true ? Colors.black : Colors.black,
//         ),
//         color: Colors.blue,
//         isSelected: isSelected,
//         selectedIcon: Icon(icon),
//       ),
//     );
//   }
//
//   Widget _textDuration(Duration duration) {
//     String twoDigits(int n) => n.toString().padLeft(2, '0');
//     final minutes = twoDigits(duration.inMinutes.remainder(60));
//     final seconds = twoDigits(duration.inSeconds.remainder(60));
//     return Text(
//       '$minutes:$seconds',
//       style: TextStyle(
//         color: widget.isFullscreen == true ? Colors.white : Colors.black,
//       ),
//     );
//   }
//
//   void _playVideo() {
//     (widget.isFullscreen == true ? _fullController : _controller).play();
//   }
//
//   void _pauseVideo() {
//     (widget.isFullscreen == true ? _fullController : _controller).pause();
//   }
//
//   void _stopVideo() {
//     (widget.isFullscreen == true ? _fullController : _controller).seekTo(
//       Duration(seconds: 0),
//     );
//     (widget.isFullscreen == true ? _fullController : _controller).pause();
//   }
//
//   Future<void> _downloadFile() async {
//     String message = await _mediaService.downloadMedia(
//       url: widget.url,
//       isImage: false,
//     );
//     if (mounted) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text(message)));
//     }
//   }
//
//   void _fullscreenVideo(videoRotation, orientation) {
//     (videoRotation == 180 || videoRotation == 270) &&
//             orientation == Orientation.portrait
//         ? setLandscapeMode()
//         : setPortraitMode();
//     if (widget.isFullscreen == true) {
//       Navigator.pop(context);
//     } else {
//       _pauseVideo();
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) {
//             return PopScope(
//               onPopInvokedWithResult: (didPop, result) {
//                 setPortraitMode();
//               },
//               child: Scaffold(
//                 backgroundColor: Colors.black,
//                 body: SafeArea(
//                   child: VideoPlayerItem(
//                     url: widget.url,
//                     isFullscreen: true,
//                     id: widget.id,
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       );
//     }
//   }
//
//   Future<void> setLandscapeMode() async {
//     await SystemChrome.setPreferredOrientations([
//       DeviceOrientation.landscapeRight,
//       DeviceOrientation.landscapeLeft,
//     ]);
//     await SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
//   }
//
//   Future<void> setPortraitMode() async {
//     await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
//     await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
//   }
// }
