import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_editor/video_editor.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatelessWidget {
  const VideoPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: const [
            VideoPlayerView(
              dataSourceType: DataSourceType.asset,
              url: 'assets/sample_video.mp4',
            ),
            SelectVideo()
          ],
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

    _videoPlayerController.initialize().then(
          (_) => setState(
            () => _chewieController = ChewieController(
                autoInitialize: true,
                videoPlayerController: _videoPlayerController,
                aspectRatio: _videoPlayerController.value.aspectRatio,
                showControlsOnInitialize: false),
          ),
        );
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
        width: double.infinity,
        child: _videoPlayerController.value.isInitialized
            ? AspectRatio(
                aspectRatio: _videoPlayerController.value.aspectRatio,
                child: Chewie(controller: _chewieController),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}

class SelectVideo extends StatefulWidget {
  const SelectVideo({super.key});

  @override
  State<SelectVideo> createState() => _SelectVideoState();
}

class _SelectVideoState extends State<SelectVideo> {
  File? _file;
  late VideoEditorController _videoEditorController;

  @override
  void dispose() {
    _videoEditorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextButton(
          onPressed: () async {
            final file =
                await ImagePicker().pickVideo(source: ImageSource.gallery);
            if (file != null) {
              setState(() {
                _file = File(file.path);
              });
            }
          },
          child: const Text('Select video'),
        ),
        if (_file != null)
          Column(
            children: [
              VideoPlayerView(
                dataSourceType: DataSourceType.file,
                url: _file!.path,
              ),
              TextButton(
                onPressed: () {
                  _videoEditorController = VideoEditorController.file(_file!);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          VideoEditorScreen(controller: _videoEditorController),
                    ),
                  );
                },
                child: const Text('Tap to edit'),
              ),
            ],
          ),
      ],
    );
  }
}

class VideoEditorScreen extends StatelessWidget {
  final VideoEditorController controller;
  const VideoEditorScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      body: VideoEditor(),
    );
  }
}
