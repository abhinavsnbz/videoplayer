import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatelessWidget {
  const VideoPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: Scaffold(
        body: VideoPlayerView(
          dataSourceType: DataSourceType.asset,
          url: 'assets/sample_video.mp4',
        ),
      ),
    );
  }
}

class VideoPlayerView extends StatefulWidget {
  const VideoPlayerView({
    super.key,
    required this.dataSourceType,
    required this.url,
  });

  final DataSourceType dataSourceType;
  final String url;

  @override
  State<VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<VideoPlayerView> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;

  @override
  void initState() {
    super.initState();
    switch (widget.dataSourceType) {
      case DataSourceType.asset:
        _videoPlayerController = VideoPlayerController.asset(widget.url);

        break;
      case DataSourceType.file:
        _videoPlayerController = VideoPlayerController.file(File(widget.url));
        break;

      case DataSourceType.network:
        _videoPlayerController = VideoPlayerController.network(widget.url);
        break;
      case DataSourceType.contentUri:
        _videoPlayerController =
            VideoPlayerController.contentUri(Uri.parse(widget.url));
        break;
    }

    _chewieController = ChewieController(
        autoInitialize: true,
        videoPlayerController: _videoPlayerController,
        aspectRatio: 16 / 9,
        showControlsOnInitialize: false);
  }

  @override
  void dispose() {
    _chewieController.dispose();
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: SizedBox(
        height: 200,
        child: Chewie(controller: _chewieController),
      ),
    );
  }
}
