import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:talent_flow/app/core/dimensions.dart';
import 'package:talent_flow/app/localization/language_constant.dart';
import 'package:video_player/video_player.dart';

import '../app/core/styles.dart';
import '../features/setting/widgets/setting_app_bar.dart';

class VideoPreviewPage extends StatefulWidget {
  final Map data;

  const VideoPreviewPage({super.key, required this.data});

  @override
  VideoPreviewPageState createState() => VideoPreviewPageState();
}

class VideoPreviewPageState extends State<VideoPreviewPage> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;

  bool _isPlaying = false;
  Duration _duration = const Duration();
  Duration _position = Duration.zero;

  @override
  void initState() {
    if (widget.data["url"] != null) {
      _controller =
          VideoPlayerController.networkUrl(Uri.parse(widget.data["url"]));
    } else {
      _controller = VideoPlayerController.file(widget.data["file"]);
    }
    _initializeVideoPlayerFuture = _controller.initialize().then((_) {
      setState(() {
        _duration = _controller.value.duration;
      });
    });

    _controller.addListener(() {
      if (_controller.value.isCompleted == true) {
        _isPlaying = false;
      }
      setState(() {
        _position = _controller.value.position;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void _playPauseVideo() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
      } else {
        _controller.play();
        _isPlaying = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: getTranslated("preview_video"),
      ),
      body: FutureBuilder(
          future: _initializeVideoPlayerFuture,
          builder: (context, snapshot) {
            return Column(
              children: [
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          VideoPlayer(_controller),
                          Visibility(
                            visible: ((snapshot.connectionState ==
                                    ConnectionState.done) &&
                                !_isPlaying),
                            child: Center(
                              child: GestureDetector(
                                onTap: _playPauseVideo,
                                child: const Icon(
                                  Icons.play_circle,
                                  size: 50,
                                  color: Styles.HINT_COLOR,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Directionality(
                        textDirection: TextDirection.ltr,
                        child: VideoProgressIndicator(
                          _controller,
                          allowScrubbing: true,
                          colors: const VideoProgressColors(
                            playedColor: Styles.PRIMARY_COLOR,
                            bufferedColor: Colors.grey,
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text(
                            '$_duration'.substring(0, 7),
                            style: const TextStyle(
                                color: Colors.black, fontSize: 12),
                          ),
                          Center(
                            child: (snapshot.connectionState ==
                                    ConnectionState.done)
                                ? IconButton(
                                    onPressed: () {
                                      _playPauseVideo();
                                    },
                                    icon: Icon(
                                      _isPlaying
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                      color: Styles.PRIMARY_COLOR,
                                      size: 30,
                                    ),
                                  )
                                : const SpinKitThreeBounce(
                                    color: Styles.PRIMARY_COLOR,
                                    size: 18,
                                  ),
                          ),
                          Text(
                            '$_position'.substring(0, 7),
                            style: const TextStyle(
                                color: Colors.black, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            );
          }),
    );
  }
}
