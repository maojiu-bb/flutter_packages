import 'package:media_carousel_wrapper/media_type.dart';

class MediaCarouselItem {
  final String mediaId;
  final String mediaUrl;
  final String thumbUrl;
  final MediaType mediaType;

  MediaCarouselItem({
    required this.mediaId,
    required this.mediaUrl,
    required this.thumbUrl,
    required this.mediaType,
  });
}
