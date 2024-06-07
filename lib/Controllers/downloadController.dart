import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:html/parser.dart' as htmlParser;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

class DownloadProviderController with ChangeNotifier {
  bool _isDownloading = false;
  String _progress = '';
  String? _localFilePath;
  String? _videoUrl = '';

  bool get isDownloading => _isDownloading;
  String get progress => _progress;
  String? get localFilePath => _localFilePath;
  String? get videoUrl => _videoUrl;

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      // Request new media permissions
      var statusImages = await Permission.photos.request();
      var statusVideos = await Permission.videos.request();
      var statusAudio = await Permission.audio.request();

      if (!statusImages.isGranted ||
          !statusVideos.isGranted ||
          !statusAudio.isGranted) {
        throw Exception('Required media permissions not granted');
      }

      // For broad file access
      if (await Permission.manageExternalStorage.request().isDenied) {
        throw Exception('Manage external storage permission not granted');
      }
    }
  }

  Future<void> fetchVideoUrl(String url) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final document = htmlParser.parse(response.body);
        final videoElement = document.querySelector('shreddit-player');

        if (videoElement != null) {
          final src = videoElement.attributes['src'];
          final json = videoElement.attributes['packaged-media-json'];

          if (json != null) {
            final jsonMap = jsonDecode(json);
            final playbackMp4s = jsonMap['playbackMp4s'];

            if (playbackMp4s != null) {
              final permutations = playbackMp4s['permutations'];

              if (permutations.isNotEmpty) {
                final source = permutations[0]['source'];
                final url = source['url'];

                _videoUrl = url;
                notifyListeners();

                return;
              }
            }
          }
        } else {
          throw Exception('Video player element not found');
        }
      } else {
        throw Exception('Failed to load webpage: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching video URL: $e');
      throw Exception('Failed to fetch video URL');
    }
  }

  Future<void> downloadVideo(String url, BuildContext context) async {
    _isDownloading = true;
    notifyListeners();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Download started...')),
    );

    try {
      // Request permissions
      await _requestPermissions();

      // Get downloads directory
      Directory? downloadsDir;
      if (Platform.isAndroid) {
        downloadsDir = Directory('/storage/emulated/0/Download');
      } else if (Platform.isIOS) {
        downloadsDir = await getApplicationDocumentsDirectory();
      }

      if (downloadsDir == null) {
        throw Exception('Could not access downloads directory');
      }

      String downloadsPath = downloadsDir.path;

      String fileName =
          'downloaded_video_${DateTime.now().millisecondsSinceEpoch}.mp4';
      String filePath = '$downloadsPath/$fileName';

      Dio dio = Dio();

      await dio.download(
        url,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            _progress = (received / total * 100).toStringAsFixed(0) + "%";
            notifyListeners();
          }
        },
      );

      _localFilePath = filePath;
      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download completed! File saved at: $filePath')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed: $e')),
      );
      throw Exception('Download failed: $e');
    } finally {
      _isDownloading = false;
      notifyListeners();
    }
  }
}
