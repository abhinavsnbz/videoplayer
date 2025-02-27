import 'package:flutter/material.dart';
import 'package:videoplayer/video_player.dart';
import 'package:videoplayer/video_trimmer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: VideoTrimmer(),
    );
  }
}
