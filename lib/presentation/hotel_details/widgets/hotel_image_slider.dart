// lib/presentation/hotel_details/widgets/hotel_image_slider.dart
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:tayyran_app/core/constants/color_constants.dart';

class HotelImageSlider extends StatefulWidget {
  final List<String> images;
  final String primaryImage;

  const HotelImageSlider({
    super.key,
    required this.images,
    required this.primaryImage,
  });

  @override
  State<HotelImageSlider> createState() => _HotelImageSliderState();
}

class _HotelImageSliderState extends State<HotelImageSlider> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _autoSlideTimer;
  bool _isUserInteracting = false;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _autoSlideTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    final images = widget.images.isNotEmpty
        ? widget.images
        : [widget.primaryImage];
    if (images.length <= 1) return;

    _autoSlideTimer = Timer.periodic(Duration(seconds: 4), (timer) {
      if (!_isUserInteracting && _pageController.hasClients) {
        final nextPage = (_currentPage + 1) % images.length;
        _pageController.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _onUserInteractionStart() {
    setState(() {
      _isUserInteracting = true;
    });
    Future.delayed(Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _isUserInteracting = false;
        });
      }
    });
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.images.isNotEmpty
        ? widget.images
        : [widget.primaryImage];
    final totalImages = images.length;

    return Stack(
      children: [
        // Image Slider
        GestureDetector(
          onPanStart: (_) => _onUserInteractionStart(),
          onVerticalDragStart: (_) => _onUserInteractionStart(),
          child: SizedBox(
            height: 280,
            child: PageView.builder(
              controller: _pageController,
              itemCount: totalImages,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                return _buildImageItem(images[index]);
              },
            ),
          ),
        ),

        // Page Indicator - Always use compact version
        if (totalImages > 1)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(child: _buildSimplePageIndicator(totalImages)),
          ),

        // Image Count Badge
        if (totalImages > 1)
          Positioned(
            top: 16,
            right: 16,
            child: _buildImageCountBadge(totalImages),
          ),

        // Navigation Arrows
        if (totalImages > 1)
          Positioned(
            left: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: _buildNavigationArrow(
                isLeft: true,
                totalImages: totalImages,
              ),
            ),
          ),

        if (totalImages > 1)
          Positioned(
            right: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: _buildNavigationArrow(
                isLeft: false,
                totalImages: totalImages,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSimplePageIndicator(int totalImages) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // CRITICAL: Prevents overflow
        children: [
          // Current page indicator
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.red,
            ),
          ),
          SizedBox(width: 8),
          // Page info
          Text(
            '${_currentPage + 1} / $totalImages',
            style: TextStyle(
              color: Colors.green,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageCountBadge(int totalImages) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${_currentPage + 1}/$totalImages',
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500, // Changed to 500 for consistency
        ),
      ),
    );
  }

  Widget _buildNavigationArrow({
    required bool isLeft,
    required int totalImages,
  }) {
    return IconButton(
      onPressed: () {
        _onUserInteractionStart();
        int targetPage;
        if (isLeft) {
          targetPage = _currentPage == 0 ? totalImages - 1 : _currentPage - 1;
        } else {
          targetPage = _currentPage == totalImages - 1 ? 0 : _currentPage + 1;
        }
        _goToPage(targetPage);
      },
      icon: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black54,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isLeft ? Icons.arrow_back_ios : Icons.arrow_forward_ios,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildImageItem(String imageUrl) {
    return Image.network(
      imageUrl,
      height: 280,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.grey[200],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.photo, size: 64, color: Colors.grey[400]),
              SizedBox(height: 8),
              Text(
                'Unable to load image',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey[200],
          child: Center(
            child: CircularProgressIndicator(
              color: AppColors.splashBackgroundColorEnd,
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
    );
  }
}
