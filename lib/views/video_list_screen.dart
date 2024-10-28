import 'dart:async';
import 'dart:typed_data';
import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoList extends StatefulWidget {
  const VideoList({super.key});

  @override
  _VideoListState createState() => _VideoListState();
}

class _VideoListState extends State<VideoList> with WidgetsBindingObserver {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  int? selectedIndex;
  bool _isFullScreen = false;

  final List<String> videoUrls = [
    /*'assets/videos/Lidar.mp4',
    'assets/videos/30_S_ad_April8.mp4',
    'assets/videos/Retractable_GearWarning.mp4',*/
    'assets/videos/SVA_BenchTestKit_testing_video_24June2024_V5.mp4',
    'assets/videos/SVA_Noice_Video_29Aug2024_V13.mp4',
    'assets/videos/SVA500-30MinuteInstallKit_Installation_V2.mp4',
    'assets/videos/GlassyGuide400_Installation_17July2024_V1.mp4',
    'assets/videos/GlassyGuide400quickInstallKit-protable_18July2024_V4.mp4',

  ];

  final List<String> videoDescriptions = [
    /*"LiDAR range 590ft, Gear warning from 560ft, No more Gear up Landings, Install SkyVoice Alert 500",
    "Fly Safely with SkyVoice Alert 500: Stress-Free Takeoffs & Landings!",
    "SkyVoice Alert 500 – Retractable Gear Warning Device from Holy Micro! LLC",*/
    "Demonstration of How to Use SkyVoice Alert Bench Test Kit",
    "Pulsating Noise in SkyVoice Alert 500 LiDAR Altimeter",
    "Install SkyVoice Alert 500 in 30 Minutes | Easy Setup Guide",
    "How to Install the SkyVoice Glassy Guide 400 on your Seaplanes",
    "SkyVoice Glassy Guide 400 Portable –Quick Install Kit",

  ];

  final Map<String, Uint8List?> _thumbnailCache = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this); // Add the observer
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this); // Remove the observer
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      _videoPlayerController?.pause();
    } else if (state == AppLifecycleState.resumed) {
      _videoPlayerController?.play();
    }
  }

  void _initializePlayer(String videoUrl) {
    _videoPlayerController = VideoPlayerController.asset(videoUrl)
      ..initialize().then((_) {
        setState(() {
          _videoPlayerController!.addListener(_onVideoPlayerControllerUpdate);
          if (AppLifecycleState.resumed !=
              WidgetsBinding.instance.lifecycleState) {
            _videoPlayerController!.pause();
          } else {
            _videoPlayerController!.play();
          }
        });
      });

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: false,
      looping: false,
      fullScreenByDefault: false,
    );

    _chewieController!.addListener(() {
      setState(() {
        _isFullScreen = _chewieController!.isFullScreen;
      });
    });
  }

  void _onVideoPlayerControllerUpdate() {
    if (_videoPlayerController!.value.isInitialized &&
        !_videoPlayerController!.value.isPlaying) {
      _videoPlayerController!.removeListener(_onVideoPlayerControllerUpdate);
      setState(() {
        _videoPlayerController!.play();
      });
    }
  }

  Future<Uint8List?> _generateThumbnail(String videoUrl) async {
    try {
      if (_thumbnailCache.containsKey(videoUrl)) {
        return _thumbnailCache[videoUrl];
      }

      final byteData = await rootBundle.load(videoUrl);
      Directory tempDir = await getTemporaryDirectory();

      File tempVideo = File("${tempDir.path}/$videoUrl")
        ..createSync(recursive: true)
        ..writeAsBytesSync(byteData.buffer
            .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

      final thumbnailPath = (await getTemporaryDirectory()).path;
      final fileName = await VideoThumbnail.thumbnailFile(
        video: tempVideo.path,
        thumbnailPath: thumbnailPath,
        imageFormat: ImageFormat.PNG,
        quality: 100,
      );
      final thumbnailBytes = await File(fileName!).readAsBytes();
      _thumbnailCache[videoUrl] = thumbnailBytes;
      return thumbnailBytes;
    } catch (e) {
      print('Error generating thumbnail: $e');
      return null;
    }
  }

  Future<bool> _onWillPop() async {
    if (_isFullScreen) {
      // Exit fullscreen mode
      _chewieController?.exitFullScreen();
      return Future.value(false); // Prevent back navigation
    }
    return Future.value(true); // Allow back navigation
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.black),
          backgroundColor: Colors.white,
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 2,
                  child: _videoPlayerController?.value.isInitialized ?? false
                      ? AspectRatio(
                    aspectRatio: _videoPlayerController!.value.aspectRatio,
                    child: SizedBox(
                      width: isLandscape ? constraints.maxWidth * 0.75 : double.infinity,
                      child: Chewie(
                        controller: _chewieController!,
                      ),
                    ),
                  )
                      : SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: isLandscape ? 120.h : 200.h,
                    child: Image.asset(
                      'assets/image/holymicro-logo-2.png',
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: FutureBuilder<List<Uint8List?>>(
                    future: Future.wait(videoUrls.map((url) => _generateThumbnail(url))),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting || snapshot.data == null) {
                        return ListView.builder(
                          itemCount: videoUrls.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (selectedIndex != index) {
                                    _videoPlayerController?.dispose();
                                    _chewieController?.dispose();
                                    _initializePlayer(videoUrls[index]);
                                    selectedIndex = index;
                                  }
                                  if (_isFullScreen) {
                                    _chewieController?.exitFullScreen();
                                  }
                                });
                              },
                              child: VideoListItem(
                                thumbnailBytes: snapshot.data?[index],
                                videoName: 'Holy Micro SkyVoice',
                                videoDescription: videoDescriptions[index],
                                isSelected: selectedIndex == index,
                              ),
                            );
                          },
                        );
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else {
                        return ListView.builder(
                          itemCount: videoUrls.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (selectedIndex != index) {
                                    _videoPlayerController?.dispose();
                                    _chewieController?.dispose();
                                    _initializePlayer(videoUrls[index]);
                                    selectedIndex = index;
                                  }
                                  if (_isFullScreen) {
                                    _chewieController?.exitFullScreen();
                                  }
                                });
                              },
                              child: VideoListItem(
                                thumbnailBytes: snapshot.data?[index],
                                videoName: 'Holy Micro SkyVoice',
                                videoDescription: videoDescriptions[index],
                                isSelected: selectedIndex == index,
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }


}

class VideoListItem extends StatelessWidget {
  final Uint8List? thumbnailBytes;
  final String videoName;
  final String videoDescription;
  final bool isSelected;

  const VideoListItem({
    Key? key,
    required this.thumbnailBytes,
    required this.videoName,
    required this.videoDescription,
    required this.isSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: isSelected ? Colors.grey.withOpacity(0.5) : null,
      ),
      child: Padding(
        padding: EdgeInsets.all(2.w),
        child: Row(
          children: [
            thumbnailBytes != null
                ? Image.memory(
              thumbnailBytes!,
              width: 150,
              height: 80,
              fit: BoxFit.fill,
            )
                : Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Container(
                width: 150,
                height: 80,
                color: Colors.grey.shade400,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    videoDescription,
                    maxLines: 2,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(
                    height: 1.h,
                  ),
                  Text(
                    videoName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, color: Colors.black45),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
