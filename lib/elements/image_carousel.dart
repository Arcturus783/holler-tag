import 'package:flutter/material.dart';
import 'dart:async';

class ImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final Duration autoScrollDuration;
  final double? screenWidth; // Add screenWidth parameter
  final double? maxHeight;
  const ImageCarousel({
    super.key,
    required this.imageUrls,
    this.autoScrollDuration = const Duration(seconds: 3),
    this.screenWidth, // Make it nullable and optional
    this.maxHeight,
  });

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;
  String? _firstImageUrl;
  double? _aspectRatio;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
    _startAutoScroll();
    _firstImageUrl = widget.imageUrls.isNotEmpty ? widget.imageUrls[0] : null;
    _aspectRatio = 16 / 9; // Initialize with a default aspect ratio
    _loadFirstImageAspectRatio();
  }

  @override
  void didUpdateWidget(covariant ImageCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imageUrls != oldWidget.imageUrls) {
      _firstImageUrl = widget.imageUrls.isNotEmpty ? widget.imageUrls[0] : null;
      _aspectRatio = 16 / 9; // Reset aspect ratio
      _loadFirstImageAspectRatio(); // Reload aspect ratio for the new list
      // Also, reset the page controller to the first page
      _currentPage = 0;
      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      } else {
        _pageController = PageController(initialPage: 0);
      }
    }
  }

  Future<void> _loadFirstImageAspectRatio() async {
    if (_firstImageUrl != null) {
      final aspectRatio = await _getFirstImageAspectRatio();
      if (aspectRatio != null && mounted) {
        setState(() {
          _aspectRatio = aspectRatio;
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(widget.autoScrollDuration, (Timer timer) {
      if (_pageController.hasClients && widget.imageUrls.isNotEmpty) {
        if (_currentPage < widget.imageUrls.length - 1) {
          _currentPage++;
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        } else {
          _currentPage = 0;
          _pageController.jumpToPage(0);
        }
      }
    });
  }

  void _previousImage() {
    if (_currentPage > 0) {
      _currentPage--;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _currentPage = widget.imageUrls.length - 1;
      _pageController.jumpToPage(_currentPage);
    }
  }

  void _nextImage() {
    if (_currentPage < widget.imageUrls.length - 1) {
      _currentPage++;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _currentPage = 0;
      _pageController.jumpToPage(_currentPage);
    }
  }

  Future<double?> _getFirstImageAspectRatio() async {
    if (_firstImageUrl != null) {
      final Completer<double?> completer = Completer<double?>();
      ImageProvider imageProvider = AssetImage(_firstImageUrl!);
      imageProvider.resolve(const ImageConfiguration()).addListener(
        ImageStreamListener((ImageInfo info, bool _) {
          final aspectRatio = info.image.width / info.image.height;
          completer.complete(aspectRatio);
        }, onError: (Object error, StackTrace? stackTrace) {
          completer.complete(null);
        }),
      );
      return completer.future;
    }
    return null;
  }

    @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double calculatedHeight = constraints.maxWidth / (_aspectRatio ?? (16 / 9));
        // double maxHeightAspectRatio = 9 / 16; // Comment out this line
        // double calculatedMaxAspectRatioHeight = constraints.maxWidth / maxHeightAspectRatio; // Comment out this line

        double finalHeight = calculatedHeight;

        // Apply the maxHeight constraint passed from HomePage
        if (widget.maxHeight != null && calculatedHeight > widget.maxHeight!) {
          finalHeight = widget.maxHeight!;
        } // else if (calculatedHeight > calculatedMaxAspectRatioHeight) { // Comment out this block
        //   finalHeight = calculatedMaxAspectRatioHeight;
        // }

        return SizedBox(
          width: double.infinity,
          height: finalHeight,
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: widget.imageUrls.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      widget.imageUrls[index],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                            child: Text('Failed to load image'));
                      },
                    ),
                  );
                },
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            size: 14,
                          ),
                          onPressed: _previousImage,
                          style: ButtonStyle(
                            padding: WidgetStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.zero),
                            minimumSize: WidgetStateProperty.all(const Size(30, 30)),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: widget.imageUrls.asMap().entries.map((entry) {
                            int index = entry.key;
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: _currentPage == index ? 18.0 : 12.0,
                              height: 5.0,
                              margin: const EdgeInsets.symmetric(horizontal: 3.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(3.0),
                                color: _currentPage == index
                                    ? Theme.of(context).primaryColor
                                    : Colors.grey,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 5.0),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_forward_ios,
                            size: 14,
                          ),
                          onPressed: _nextImage,
                          style: ButtonStyle(
                            padding: WidgetStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.zero),
                            minimumSize: WidgetStateProperty.all(const Size(30, 30)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}