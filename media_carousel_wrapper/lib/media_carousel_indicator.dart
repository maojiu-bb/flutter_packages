import 'package:flutter/material.dart';
import 'package:media_carousel_wrapper/cached_image_widget.dart';
import 'package:media_carousel_wrapper/media_carousel_controller.dart';

class MediaCarouselIndicator extends StatefulWidget {
  final MediaCarouselController controller;
  final double height;
  final double itemWidth;
  final EdgeInsetsGeometry padding;
  final Color selectedBorderColor;
  final Color borderColor;
  final double borderRadius;
  final double spacing;

  const MediaCarouselIndicator({
    super.key,
    required this.controller,
    this.height = 100,
    this.itemWidth = 80,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
    this.selectedBorderColor = Colors.white,
    this.borderColor = Colors.transparent,
    this.borderRadius = 16,
    this.spacing = 15,
  });

  @override
  State<MediaCarouselIndicator> createState() => _MediaCarouselIndicatorState();
}

class _MediaCarouselIndicatorState extends State<MediaCarouselIndicator> {
  MediaCarouselController get controller => widget.controller;

  @override
  void initState() {
    super.initState();
    controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaList = controller.mediaList;
    final currentIndex = controller.currentIndex;

    if (mediaList.length <= 1) return const SizedBox.shrink();

    return SizedBox(
      height: widget.height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: widget.padding,
        itemBuilder: (BuildContext context, int index) {
          final item = mediaList[index];
          final isSelected = currentIndex == index;

          return GestureDetector(
            onTap: () {
              controller.animateToIndex(index);
            },
            child: Container(
              width: widget.itemWidth,
              height: widget.height,
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected ? widget.selectedBorderColor : widget.borderColor,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(widget.borderRadius),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                child: CachedImageWidget(
                  imageUrl: item.thumbUrl,
                  width: widget.itemWidth,
                  height: widget.height,
                  fit: BoxFit.cover,
                  placeholderImageUrl: controller.placeholderImageUrl,
                ),
              ),
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return SizedBox(width: widget.spacing);
        },
        itemCount: mediaList.length,
      ),
    );
  }
}
