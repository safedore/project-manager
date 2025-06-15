import 'dart:developer';
import 'dart:io';
import 'package:android_path_provider/android_path_provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';

class MediaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> uploadMedia({
    required String projectId,
    required bool isImage,
  }) async {
    try {
      final status = isImage
          ? await Permission.photos.request()
          : await Permission.videos.request();
      if (!status.isGranted) {
        log("Storage permission denied.");
        return;
      }

      final result = await FilePicker.platform.pickFiles(
        type: isImage ? FileType.image : FileType.video,
      );

      if (result == null || result.files.single.path == null) {
        log("No file selected.");
        return;
      }

      final pickedFile = File(result.files.single.path!);

      if (!await pickedFile.exists()) {
        log("File does not exist.");
        return;
      }

      final appDir = await getApplicationDocumentsDirectory();

      // 'media' subfolder for each project
      final projectDir = Directory('${appDir.path}/projects/$projectId');
      if (!await projectDir.exists()) {
        await projectDir.create(recursive: true);
      }

      // local file name
      final fileExtension = path.extension(pickedFile.path);
      final fileName = '${DateTime.now().millisecondsSinceEpoch}$fileExtension';
      final savedPath = path.join(projectDir.path, fileName);

      // copy file to app directory
      final savedFile = await pickedFile.copy(savedPath);
      log("Saved locally at: ${savedFile.path}");

      // save above paths to firestore
      await _firestore.collection('projects').doc(projectId).set({
        isImage ? 'imageUrls' : 'videoUrls': FieldValue.arrayUnion([
          savedFile.path,
        ]),
      }, SetOptions(merge: true));
    } catch (e) {
      log('Unexpected error: $e');
    }
  }

  Future<String> downloadMedia({
    required String url,
    required bool isImage,
  }) async {
    String message = '';
    try {
      if (url.isEmpty) {
        message = "No media found for this project.";
        log(message);
        return message;
      }

      final String filePath = url;
      final File originalFile = File(filePath);

      if (!await originalFile.exists()) {
        message = "File not found.";
        log(message);
        return message;
      }

      final status = await requestStoragePermissions();
      // final status = await Permission.storage.request();
      if (status != 'granted') {
        message = "Storage permission denied.";
        log(message);
        return message;
      }

      // downloads directory
      final String downloadsDir = await AndroidPathProvider.downloadsPath;
      if (downloadsDir == '') {
        message = "Could not find downloads directory.";
        log(message);
        return message;
      }

      final fileName = 'media_${path.basename(filePath)}';
      // final fileName = 'media_${DateTime.now().millisecondsSinceEpoch}$fileExtension';
      final savedPath = path.join(downloadsDir, fileName);
      if (await File(savedPath).exists()) {
        return 'Media already exists at $savedPath';
      }
      // copy file to Downloads
      final savedFile = await originalFile.copy(savedPath);

      message = "Media saved to: ${savedFile.path}";
      log(message);
      return message;
    } catch (e) {
      message = "Download error: $e";
      log(message);
      return message;
    }
  }

  Future<String> deleteMedia({
    required String url,
    required String projectId,
    required bool isImage,
  }) async {
    String message = '';
    try {
      // delete from local
      if (url.isNotEmpty && await File(url).exists()) {
        await File(url).delete();
      }

      // delete media
      final field = isImage ? 'imageUrls' : 'videoUrls';
      await FirebaseFirestore.instance
          .collection('projects')
          .doc(projectId)
          .update({
            field: FieldValue.arrayRemove([url]),
          });

      return 'Media deleted successfully.';
    } catch (e) {
      message = "Delete error: $e";
      return message;
    }
  }

  Future<String> checkDownloadedMedia({required String url}) async {
    String message = '';
    try {
      if (url.isEmpty) {
        return '';
      }

      final String filePath = url;
      final String downloadsDir = await AndroidPathProvider.downloadsPath;
      if (downloadsDir == '') {
        message = "";
        log(message);
        return message;
      }

      final fileName = 'media_${path.basename(filePath)}';
      final savedPath = path.join(downloadsDir, fileName);

      if (savedPath.isEmpty) {
        return '';
      }

      if (!await File(savedPath).exists()) {
        return '';
      }

      message = savedPath;
      log(message);
      return message;
    } catch (e) {
      return '';
    }
  }

  Future<String> requestStoragePermissions() async {
    if (!Platform.isAndroid) return 'Not Android';

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    PermissionStatus status;

    if (sdkInt >= 33) {
      // Android 13+ (API 33+) — request new granular media permissions
      final photosStatus = await Permission.photos.request();
      final videosStatus = await Permission.videos.request();

      if (photosStatus.isGranted || videosStatus.isGranted) {
        return 'granted';
      } else {
        return 'denied';
      }
    } else if (sdkInt >= 30) {
      // Android 11–12 (API 30–32)
      status = await Permission.storage.request();

      if (status.isGranted) {
        return 'granted';
      }

      return 'denied';
    } else {
      // Android 10 and below
      status = await Permission.storage.request();
      if (status.isGranted) {
        return 'granted';
      } else {
        return 'denied';
      }
    }
  }
}
