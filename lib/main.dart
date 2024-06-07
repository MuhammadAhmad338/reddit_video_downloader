import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:myfirstflutterproject/Controllers/imageController.dart';
import 'package:myfirstflutterproject/Controllers/themeController.dart';
import 'package:myfirstflutterproject/Views/videoScreen.dart';
import 'package:myfirstflutterproject/firebase_options.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => ImageUploadProviderController()),
    ChangeNotifierProvider(create: (_) => ThemeProviderController()),
  ], child: const MyApp()));
}

// Top-level function for the download callback

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Latest Project',
        debugShowCheckedModeBanner: false,
        theme: Provider.of<ThemeProviderController>(context).currentTheme,
        home: const VideoUrlParserPage());
  }
}
