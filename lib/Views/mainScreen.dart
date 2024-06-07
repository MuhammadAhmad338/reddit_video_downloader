// ignore_for_file: file_names, null_check_always_fails, avoid_print, unnecessary_null_comparison, library_private_types_in_public_api
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class VideoDownloader extends StatefulWidget {
  const VideoDownloader({super.key});

  @override
  _VideoDownloaderState createState() => _VideoDownloaderState();
}

class _VideoDownloaderState extends State<VideoDownloader> {
  final TextEditingController _postUrlController = TextEditingController();
  String _status = 'Enter a Reddit post URL to download the video';

  Future<String> _fetchVideoUrl(String postUrl) async {
    try {
      // Fetch the page content
      final response = await http.get(Uri.parse(postUrl));
      if (response.statusCode != 200) {
        return null!;
      }

      // Parse the page content
      final document = html_parser.parse(response.body);

      // Find the video URL in the <shreddit-player> tag
      final shredderPlayer = document.querySelector('shreddit-player');
      if (shredderPlayer != null) {
        final sourceTag = shredderPlayer.querySelector('source');
        if (sourceTag != null) {
          final videoUrl = sourceTag.attributes['src'];
          print(videoUrl);
          return videoUrl!;
        }
      }

      return null!;
    } catch (e) {
      print('Error fetching video URL: $e');
      return null!;
    }
  }

  Future<Directory> _getDownloadDirectory() async {
    Directory? directory;

    if (Platform.isAndroid) {
      // Request storage permissions if not already granted

      directory = await getExternalStorageDirectory();
    } else if (Platform.isIOS) {
      directory = await getApplicationDocumentsDirectory();
    } else {
      throw UnsupportedError('Unsupported platform');
    }

    if (directory == null) {
      throw Exception('Could not retrieve directory');
    }

    return directory;
  }

  Future<void> _downloadVideo(String url) async {
    setState(() {
      _status = 'Downloading...';
    });

    // Request storage permissions

    try {
      // Fetch video data
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        // Get the directory to save the video
        Directory dir = await _getDownloadDirectory();
        String timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
        String filePath = '${dir.path}/video_$timestamp.mp4';

        // Save the video file
        File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        setState(() {
          _status = 'Download completed: $filePath';
        });
      } else {
        setState(() {
          _status = 'Failed to download video';
        });
      }
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    }
  }

  Future<void> _fetchAndDownloadVideo(String postUrl) async {
    setState(() {
      _status = 'Fetching video URL...';
    });

    final videoUrl = await _fetchVideoUrl(postUrl);

    if (videoUrl != null) {
      await _downloadVideo(videoUrl);
    } else {
      setState(() {
        _status = 'Failed to fetch video URL';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Reddit Video Downloader'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _postUrlController,
              decoration: const InputDecoration(
                labelText: 'Reddit Post URL',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _fetchAndDownloadVideo(_postUrlController.text),
              child: const Text(
                'Fetch and Download Video',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _status,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
