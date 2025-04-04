import 'package:flutter/material.dart';
import 'dart:async';

class ImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final Duration autoScrollDuration;
  final double? screenWidth; // Add screenWidth parameter

  const ImageCarousel({
    super.key,
    required this.imageUrls,
    this.autoScrollDuration = const Duration(seconds: 3),
    this.screenWidth, // Make it nullable and optional
  });

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
    _startAutoScroll();
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
          _pageController.jumpToPage(0); // Directly jump to the first page
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
      _currentPage = widget.imageUrls.length - 1; // Go to the last image
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
      _currentPage = 0; // Go to the first image
      _pageController.jumpToPage(_currentPage);
    }
  }

  @override
  Widget build(BuildContext context) {
    double desiredAspectRatio = 16 / 9;
    double carouselHeight = widget.screenWidth != null
        ? widget.screenWidth! / desiredAspectRatio
        : 200.0;

    return SizedBox(
      height: carouselHeight,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.imageUrls.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Image.network(
                  widget.imageUrls[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Text('Failed to load image'));
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
              padding: const EdgeInsets.only(bottom: 15.0), // Adjust bottom padding to move upwards
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding( // Left button
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
                  Padding( // Scroll indicator
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
                  Padding( // Right button
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
  }
}