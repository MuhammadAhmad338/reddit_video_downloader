import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as htmlParser;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class VideoUrlParserPage extends StatefulWidget {
  const VideoUrlParserPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _VideoUrlParserPageState createState() => _VideoUrlParserPageState();
}

class _VideoUrlParserPageState extends State<VideoUrlParserPage> {
  TextEditingController urlController = TextEditingController();
  String videoUrl = '';
  bool _isDownloading = false;
  String _progress = "";
  String _localFilePath = "";

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

                setState(() {
                  videoUrl = url;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Video URL fetched: $videoUrl')),
                );

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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch video URL')),
      );
    }
  }

  Future<void> _downloadVideo(String url) async {
    setState(() {
      _isDownloading = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Download started...')),
    );
    try {
      Directory? downloadsDir = await getExternalStorageDirectory();
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
            setState(() {
              _progress = (received / total * 100).toStringAsFixed(0) + "%";
            });
          }
        },
      );

      setState(() {
        _localFilePath = filePath;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download completed! File saved at: $filePath')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed: $e')),
      );
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Video URL Parser',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: urlController,
                decoration: const InputDecoration(
                  labelText: 'Enter URL',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  fetchVideoUrl(urlController.text.trim());
                },
                child: const Text(
                  'Fetch Video URL',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16.0),
              if (videoUrl.isNotEmpty) ...[
                Text(
                  'Video URL: $videoUrl',
                  style: const TextStyle(fontSize: 16.0),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    _downloadVideo(videoUrl);
                  },
                  child: const Text('Download Video'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
