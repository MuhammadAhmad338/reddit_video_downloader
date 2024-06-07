// ignore: file_names
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../Helpers/const.dart';

class ImageUploadProviderController with ChangeNotifier {
  File? _image;
  File? get image => _image;

  Future<void> pickImage(BuildContext context) async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _image = File(pickedFile.path);
      notifyListeners();
    } else {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No Image Selected'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> uploadImage(BuildContext context) async {
    if (_image == null) return;

    final fileName = _image!.path.split('/').last;
    final storageRef = storage.ref().child('uploads/$fileName');

    try {
      await storageRef.putFile(_image!);
      final downloadUrl = await storageRef.getDownloadURL();

      // Save filename and image URL to Firestore
      await firestore.collection('records').add({
        'filename': fileName,
        'imageUrl': downloadUrl,
        'timestamp': Timestamp.now(),
      });

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image uploaded successfully.'),
          backgroundColor: Colors.green,
        ),
      );
      _image = null;
      notifyListeners();
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image uploaded failed.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
