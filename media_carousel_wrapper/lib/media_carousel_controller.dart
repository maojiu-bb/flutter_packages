import 'package:flutter/material.dart';
import 'package:media_carousel_wrapper/media_carousel_item.dart';

class MediaCarouselController extends ChangeNotifier {
  MediaCarouselController({
    required List<MediaCarouselItem> mediaList,
    int initialIndex = 0,
    required String placeholderImageUrl,
  })  : _mediaList = mediaList,
        _currentIndex = initialIndex,
        _placeholderImageUrl = placeholderImageUrl {
    _pageController = PageController(initialPage: _currentIndex);
  }

  late final PageController _pageController;
  List<MediaCarouselItem> _mediaList;
  int _currentIndex;
  final String _placeholderImageUrl;
  List<MediaCarouselItem> get mediaList => _mediaList;
  int get currentIndex => _currentIndex;
  PageController get pageController => _pageController;
  String get placeholderImageUrl => _placeholderImageUrl;

  void updateMediaList(List<MediaCarouselItem> list, {int initialIndex = 0}) {
    _mediaList = list;
    _currentIndex = initialIndex;
    if (_pageController.hasClients) {
      _pageController.jumpToPage(initialIndex);
    }
    notifyListeners();
  }

  void setCurrentIndex(int index) {
    if (_currentIndex == index) return;
    _currentIndex = index;
    notifyListeners();
  }

  void animateToIndex(int index) {
    setCurrentIndex(index);
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void jumpToIndex(int index) {
    setCurrentIndex(index);
    _pageController.jumpToPage(index);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
