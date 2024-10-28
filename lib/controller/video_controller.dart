import 'dart:async';
import 'dart:typed_data';
import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class VideoListController extends GetxController {
  final videoUrls = [
    'assets/videos/Sun_Fun.mp4',
    'assets/videos/10_S_ad_April8.mp4',
    'assets/videos/20_S_ad_April8.mp4',
    'assets/videos/Fly_Safely.mp4',
    // Add more video URLs as needed
  ].obs;

  final videoDescriptions = [
    "SkyVoice Alert LHA 500 - SUN 'n FUN Aerospace Expo - Booth # D-54",
    "Takeoffs and Landings Made Easy with SkyVoice Alert 500 Take-off and Landing Height Announcer",
    "SkyVoice Alert 500 Take-off and Landing Height Announcer: Stress-Free Takeoffs & Landings",
    "Fly Safely with SkyVoice Alert 500: Stress-Free Takeoffs & Landings!",
    // Add more descriptions as needed
  ].obs;

  final selectedIndex = 0.obs;

  // Map to store cached thumbnails
  final thumbnailCache = <String, Uint8List>{}.obs;

  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void onInit() {
    super.onInit();
    WidgetsFlutterBinding.ensureInitialized();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    _initializePlayer(videoUrls.first);
  }

  @override
  void onClose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.onClose();
  }

  void _initializePlayer(String videoUrl) async {
    _videoPlayerController = VideoPlayerController.asset(videoUrl)
      ..initialize().then((_) {
        _videoPlayerController!.addListener(_onVideoPlayerControllerUpdate);
        _videoPlayerController!.play();
        update(); // Update UI with new player state
      });

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: false,
      looping: false,
    );
  }

  void _onVideoPlayerControllerUpdate() {
    if (_videoPlayerController!.value.isInitialized &&
        !_videoPlayerController!.value.isPlaying) {
      _videoPlayerController!.removeListener(_onVideoPlayerControllerUpdate);
      _videoPlayerController!.play();
    }
  }

  Future<Uint8List?> _generateThumbnail(String videoUrl) async {
    if (thumbnailCache.containsKey(videoUrl)) {
      return thumbnailCache[videoUrl];
    }

    try {
      final byteData = await rootBundle.load(videoUrl);
      final tempDir = await getTemporaryDirectory();
      final tempVideo = File("${tempDir.path}/$videoUrl")
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
      thumbnailCache[videoUrl] = thumbnailBytes;
      return thumbnailBytes;
    } catch (e) {
      print('Error generating thumbnail: $e');
      return null;
    }
  }

  void selectVideo(int index) {
    selectedIndex.value = index;
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    _initializePlayer(videoUrls[index]);
  }

  VideoPlayerController? get videoPlayerController => _videoPlayerController;

  ChewieController? get chewieController => _chewieController;

}