import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_trimmer/video_trimmer.dart';

class VideoTrimmer extends StatelessWidget {
  const VideoTrimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: const Text("LOAD VIDEO"),
          onPressed: () async {
            FilePickerResult? result = await FilePicker.platform.pickFiles(
              type: FileType.video,
              allowCompression: false,
            );
            if (result != null) {
              File file = File(result.files.single.path!);
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) {
                  return Expanded(child: TrimmerView(file));
                }),
              );
            }
          },
        ),
      ),
    );
  }
}

class TrimmerView extends StatefulWidget {
  final File file;

  TrimmerView(this.file);

  @override
  _TrimmerViewState createState() => _TrimmerViewState();
}

class _TrimmerViewState extends State<TrimmerView> {
  final Trimmer _trimmer = Trimmer();

  bool _isPlaying = false;
  bool _progressVisibility = false;
  double _startValue = 0.0;
  double _endValue = 0.0;
  bool _isMuted = false;
  String? _originalVideoPath;

  Future<String?> _saveVideo() async {
    setState(() {
      _progressVisibility = true;
    });

    String? value;

    if (_startValue.isFinite && _endValue.isFinite) {
      await _trimmer.saveTrimmedVideo(
        startValue: _startValue,
        endValue: _endValue,
        onSave: (String? outputPath) {
          setState(() {
            _progressVisibility = false;
            value = outputPath;
          });
        },
      );
    } else {}

    return value;
  }

  Future<String?> _removeAudio(File videoFile) async {
    final info = await VideoCompress.compressVideo(
      videoFile.path,
      deleteOrigin: false,
      includeAudio: false,
      quality: VideoQuality.DefaultQuality,
    );

    if (info != null) {
      return info.path;
    }

    return null;
  }

  void _loadOriginalVideo() {
    if (_originalVideoPath != null) {
      _trimmer.loadVideo(videoFile: File(_originalVideoPath!));
    }
  }

  void _loadVideo() {
    _trimmer.loadVideo(videoFile: widget.file);
  }

  @override
  void initState() {
    super.initState();
    _loadVideo();
    _originalVideoPath = widget.file.path;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Builder(
        builder: (context) => Center(
          child: Container(
            padding: const EdgeInsets.only(bottom: 30.0, top: 25),
            color: Colors.black,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Visibility(
                  visible: _progressVisibility,
                  child: const LinearProgressIndicator(
                    backgroundColor: Colors.red,
                  ),
                ),
                ElevatedButton(
                  onPressed: _progressVisibility
                      ? null
                      : () async {
                          _saveVideo().then((outputPath) {
                            print('OUTPUT PATH: $outputPath');
                            const snackBar =
                                SnackBar(content: Text('Video Saved'));
                            ScaffoldMessenger.of(context).showSnackBar(
                              snackBar,
                            );
                          });
                        },
                  child: const Text("SAVE"),
                ),
                Expanded(
                  child: VideoViewer(trimmer: _trimmer),
                ),
                Center(
                  child: TrimViewer(
                    trimmer: _trimmer,
                    viewerHeight: 50.0,
                    viewerWidth: MediaQuery.of(context).size.width,
                    maxVideoLength: const Duration(seconds: 5),
                    onChangeStart: (value) {
                      if (value.isFinite) {
                        setState(() {
                          _startValue = value;
                        });
                      }
                    },
                    onChangeEnd: (value) {
                      if (value.isFinite) {
                        setState(() {
                          _endValue = value;
                        });
                      }
                    },
                    onChangePlaybackState: (value) =>
                        setState(() => _isPlaying = value),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      child: _isPlaying
                          ? const Icon(
                              Icons.pause,
                              size: 50.0,
                              color: Colors.white,
                            )
                          : const Icon(
                              Icons.play_arrow,
                              size: 50.0,
                              color: Colors.white,
                            ),
                      onPressed: () async {
                        bool playbackState =
                            await _trimmer.videoPlaybackControl(
                          startValue: _startValue,
                          endValue: _endValue,
                        );
                        setState(
                          () {
                            _isPlaying = playbackState;
                          },
                        );
                      },
                    ),
                    TextButton(
                      onPressed: () async {
                        if (_progressVisibility) return;

                        setState(() {
                          _progressVisibility = true;
                        });

                        if (_isMuted) {
                          _loadOriginalVideo();
                          setState(() {
                            _isMuted = false;
                            _progressVisibility = false;
                          });
                        } else {
                          final videoWithoutAudioPath =
                              await _removeAudio(widget.file);

                          if (videoWithoutAudioPath != null) {
                            _trimmer.loadVideo(
                                videoFile: File(videoWithoutAudioPath));
                            setState(() {
                              _isMuted = true;
                              _progressVisibility = false;
                            });
                          }
                        }
                      },
                      child: _isMuted
                          ? const Icon(
                              Icons.volume_up_outlined,
                              size: 50.0,
                              color: Colors.white,
                            )
                          : const Icon(
                              Icons.volume_off_outlined,
                              size: 50.0,
                              color: Colors.white,
                            ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
