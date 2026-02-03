import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:media_carousel_wrapper/cached_image_widget.dart';
import 'package:media_carousel_wrapper/loading_widget.dart';
import 'package:media_carousel_wrapper/media_carousel_controller.dart';
import 'package:media_carousel_wrapper/media_carousel_item.dart';
import 'package:media_carousel_wrapper/media_type.dart';
import 'package:video_player/video_player.dart';

class MediaCarouselWrapper extends StatefulWidget {
  final MediaCarouselController controller;
  final double height;
  final Gradient gradient;
  final Color? loadingColor;

  const MediaCarouselWrapper({
    super.key,
    required this.controller,
    this.height = 550,
    this.gradient = const LinearGradient(
      colors: [
        Colors.transparent,
        Colors.black,
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      stops: [0.8, 1.0],
    ),
    this.loadingColor,
  });

  @override
  State<MediaCarouselWrapper> createState() => _MediaCarouselWrapperState();
}

class _MediaCarouselWrapperState extends State<MediaCarouselWrapper> {
  Map<String, (VideoPlayerController, ChewieController)> videoPlayerMap = {};
  Set<String> initializingVideos = {};

  MediaCarouselController get controller => widget.controller;
  List<MediaCarouselItem> get mediaList => controller.mediaList;
  int get currentIndex => controller.currentIndex;
  PageController get pageController => controller.pageController;

  @override
  void initState() {
    super.initState();
    controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  Future<void> initAndPlayVideo(String mediaId, String mediaUrl) async {
    if (initializingVideos.contains(mediaId)) return;
    initializingVideos.add(mediaId);

    try {
      final videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(mediaUrl));
      await videoPlayerController.initialize();
      final chewieController = ChewieController(
        videoPlayerController: videoPlayerController,
        autoPlay: true,
        looping: true,
        showControls: false,
      );
      videoPlayerMap[mediaId] = (videoPlayerController, chewieController);
      if (mounted) setState(() {});
    } catch (e) {
      initializingVideos.remove(mediaId);
      debugPrint('Video init error: $e');
    }
  }

  @override
  void dispose() {
    controller.removeListener(_onControllerChanged);
    videoPlayerMap.forEach((key, value) {
      value.$1.dispose();
      value.$2.dispose();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (mediaList.isEmpty) return const SizedBox.shrink();

    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: widget.height,
          child: PageView.builder(
            controller: pageController,
            onPageChanged: (index) {
              controller.setCurrentIndex(index);
            },
            itemBuilder: (BuildContext context, int index) {
              final item = mediaList[index];

              if (item.mediaType == MediaType.photo) {
                return CachedImageWidget(
                  imageUrl: item.mediaUrl,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  placeholderImageUrl: controller.placeholderImageUrl,
                );
              } else {
                final controllers = videoPlayerMap[item.mediaId];

                // 视频未初始化，触发初始化并显示缩略图
                if (controllers == null) {
                  initAndPlayVideo(item.mediaId, item.mediaUrl);
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      CachedImageWidget(
                        imageUrl: item.thumbUrl,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        placeholderImageUrl: controller.placeholderImageUrl,
                      ),
                      LoadingWidget(loadingColor: widget.loadingColor),
                    ],
                  );
                }

                final videoPlayerController = controllers.$1;
                final chewieController = controllers.$2;

                return ClipRRect(
                  child: Container(
                    color: Colors.black,
                    width: double.infinity,
                    height: double.infinity,
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: videoPlayerController.value.size.width,
                        height: videoPlayerController.value.size.height,
                        child: Chewie(controller: chewieController),
                      ),
                    ),
                  ),
                );
              }
            },
            itemCount: mediaList.length,
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(
            ignoring: true,
            child: Container(
              decoration: BoxDecoration(
                gradient: widget.gradient,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
