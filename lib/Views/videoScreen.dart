import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Controllers/downloadController.dart';

class VideoUrlParserPage extends StatefulWidget {
  const VideoUrlParserPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _VideoUrlParserPageState createState() => _VideoUrlParserPageState();
}

class _VideoUrlParserPageState extends State<VideoUrlParserPage> {
  TextEditingController urlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DownloadProviderController>(context);
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
                  provider.fetchVideoUrl(urlController.text.trim());
                },
                child: const Text(
                  'Fetch Video URL',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16.0),
              if (provider.videoUrl!.isNotEmpty) ...[
                Text(
                  'Video URL: ${provider.videoUrl}',
                  style: const TextStyle(fontSize: 16.0),
                ),
                const SizedBox(height: 16.0),
                ElevatedButton(
                  onPressed: () {
                    provider.downloadVideo(provider.videoUrl!, context);
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
