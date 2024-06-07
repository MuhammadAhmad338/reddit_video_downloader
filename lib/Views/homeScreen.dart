// ignore: file_names
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Controllers/imageController.dart';
import 'package:myfirstflutterproject/Controllers/themeController.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final imageUploadProvider = Provider.of<ImageUploadProviderController>(context);
    final themeProvider = Provider.of<ThemeProviderController>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Image Picker Provider',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            imageUploadProvider.image == null
                ? const Text('No image selected.')
                : Image.file(imageUploadProvider.image!),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => imageUploadProvider.pickImage(context),
              child: const Text('Pick Image'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => imageUploadProvider.uploadImage(context),
              child: const Text('Upload Image'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => themeProvider.toggleTheme(),
              child: const Text('Theme Provider'),
            ),
          ],
        ),
      ),
    );
  }
}
