import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CachedImageWidget extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;
  final BoxFit fit;
  final String placeholderImageUrl;
  final BorderRadius? borderRadius;

  const CachedImageWidget({
    super.key,
    required this.imageUrl,
    this.width = 100,
    this.height = 100,
    this.fit = BoxFit.cover,
    this.borderRadius,
    required this.placeholderImageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => Image.asset(
          placeholderImageUrl,
          width: width,
          height: height,
          fit: BoxFit.cover,
        ),
        errorWidget: (context, url, error) => Image.asset(
          placeholderImageUrl,
          width: width,
          height: height,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
