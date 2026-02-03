# Media Carousel Wrapper

A Flutter package for creating media carousels that support both images and videos with smooth animations, caching, and customizable indicators.

## Features

- Support for both **photos** and **videos** in the same carousel
- Automatic video playback with looping
- Image caching with placeholder support
- Customizable thumbnail indicator
- Smooth page transitions with animation support
- Gradient overlay support
- Controller-based state management

## Getting Started

### Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  media_carousel_wrapper:
    git:
      url: https://github.com/your-repo/media_carousel_wrapper.git
```

Or if published to pub.dev:

```yaml
dependencies:
  media_carousel_wrapper: ^0.0.1
```

### Dependencies

This package depends on:
- `chewie: 1.10.0`
- `video_player: 2.9.1`
- `cached_network_image: 3.4.1`

## Usage

### Basic Example

```dart
import 'package:flutter/material.dart';
import 'package:media_carousel_wrapper/media_carousel_wrapper.dart';
import 'package:media_carousel_wrapper/media_carousel_controller.dart';
import 'package:media_carousel_wrapper/media_carousel_indicator.dart';
import 'package:media_carousel_wrapper/media_carousel_item.dart';
import 'package:media_carousel_wrapper/media_type.dart';

class MyCarouselPage extends StatefulWidget {
  @override
  State<MyCarouselPage> createState() => _MyCarouselPageState();
}

class _MyCarouselPageState extends State<MyCarouselPage> {
  late MediaCarouselController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MediaCarouselController(
      mediaList: [
        MediaCarouselItem(
          mediaId: '1',
          mediaUrl: 'https://example.com/image1.jpg',
          thumbUrl: 'https://example.com/thumb1.jpg',
          mediaType: MediaType.photo,
        ),
        MediaCarouselItem(
          mediaId: '2',
          mediaUrl: 'https://example.com/video1.mp4',
          thumbUrl: 'https://example.com/video_thumb1.jpg',
          mediaType: MediaType.video,
        ),
      ],
      initialIndex: 0,
      placeholderImageUrl: 'assets/images/placeholder.png',
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Main carousel
          MediaCarouselWrapper(
            controller: _controller,
            height: 550,
            loadingColor: Colors.white,
          ),

          // Thumbnail indicator
          MediaCarouselIndicator(
            controller: _controller,
            height: 100,
            itemWidth: 80,
            selectedBorderColor: Colors.white,
          ),
        ],
      ),
    );
  }
}
```

### MediaCarouselController

The controller manages the carousel state and provides methods for navigation:

```dart
// Create controller
final controller = MediaCarouselController(
  mediaList: [...],
  initialIndex: 0,
  placeholderImageUrl: 'assets/placeholder.png',
);

// Update media list
controller.updateMediaList(newList, initialIndex: 0);

// Navigate with animation
controller.animateToIndex(2);

// Navigate instantly
controller.jumpToIndex(2);

// Get current state
int currentIndex = controller.currentIndex;
List<MediaCarouselItem> mediaList = controller.mediaList;
```

### MediaCarouselWrapper

The main carousel widget:

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `controller` | `MediaCarouselController` | required | The carousel controller |
| `height` | `double` | `550` | Height of the carousel |
| `gradient` | `Gradient` | Linear gradient (transparent to black) | Overlay gradient |
| `loadingColor` | `Color?` | `Colors.white` | Loading indicator color |

### MediaCarouselIndicator

The thumbnail indicator widget:

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `controller` | `MediaCarouselController` | required | The carousel controller |
| `height` | `double` | `100` | Height of the indicator |
| `itemWidth` | `double` | `80` | Width of each thumbnail |
| `padding` | `EdgeInsetsGeometry` | `horizontal: 20` | Padding around the list |
| `selectedBorderColor` | `Color` | `Colors.white` | Border color for selected item |
| `borderColor` | `Color` | `Colors.transparent` | Border color for unselected items |
| `borderRadius` | `double` | `16` | Border radius of thumbnails |
| `spacing` | `double` | `15` | Spacing between thumbnails |

### MediaCarouselItem

Data model for carousel items:

```dart
MediaCarouselItem(
  mediaId: 'unique_id',      // Unique identifier
  mediaUrl: 'url_to_media',  // URL of the image or video
  thumbUrl: 'url_to_thumb',  // Thumbnail URL (used for indicator and video placeholder)
  mediaType: MediaType.photo, // MediaType.photo or MediaType.video
)
```

### Custom Gradient

You can customize the overlay gradient:

```dart
MediaCarouselWrapper(
  controller: _controller,
  gradient: LinearGradient(
    colors: [
      Colors.transparent,
      Colors.black.withOpacity(0.8),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.5, 1.0],
  ),
)
```

## Additional Information

### Platform Support

- iOS
- Android
- Web (with video player limitations)

### Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### License

This project is licensed under the MIT License.
