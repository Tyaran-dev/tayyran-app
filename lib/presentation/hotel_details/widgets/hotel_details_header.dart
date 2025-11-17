// // lib/presentation/hotel_details/widgets/hotel_details_header.dart
// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:tayyran_app/data/models/hotel_search_model.dart';

// class HotelDetailsHeader extends StatefulWidget {
//   final HotelData hotel;

//   const HotelDetailsHeader({super.key, required this.hotel});

//   @override
//   State<HotelDetailsHeader> createState() => _HotelDetailsHeaderState();
// }

// class _HotelDetailsHeaderState extends State<HotelDetailsHeader> {
//   final PageController _pageController = PageController();
//   int _currentPage = 0;
//   Timer? _timer;

//   @override
//   void initState() {
//     super.initState();
//     _startAutoSlide();
//   }

//   @override
//   void dispose() {
//     _timer?.cancel();
//     _pageController.dispose();
//     super.dispose();
//   }

//   void _startAutoSlide() {
//     final images = widget.hotel.images.isNotEmpty
//         ? widget.hotel.images
//         : [widget.hotel.image];
//     if (images.length <= 1) return;

//     _timer = Timer.periodic(Duration(seconds: 5), (timer) {
//       if (_pageController.hasClients) {
//         final nextPage = (_currentPage + 1) % images.length;
//         _pageController.animateToPage(
//           nextPage,
//           duration: Duration(milliseconds: 500),
//           curve: Curves.easeInOut,
//         );
//       }
//     });
//   }

//   void _onPageChanged(int page) {
//     setState(() {
//       _currentPage = page;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final images = widget.hotel.images.isNotEmpty
//         ? widget.hotel.images
//         : [widget.hotel.image];

//     return Column(
//       children: [
//         // Image Gallery with Auto Slider
//         _buildImageSlider(images),

//         // Hotel Info
//         Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Hotel Name and Rating
//               Row(
//                 children: [
//                   Expanded(
//                     child: Text(
//                       widget.hotel.hotelName,
//                       style: TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   _buildRatingBadge(),
//                 ],
//               ),

//               SizedBox(height: 8),

//               // Location
//               Row(
//                 children: [
//                   Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
//                   SizedBox(width: 4),
//                   Expanded(
//                     child: Text(
//                       '${widget.hotel.cityName}, ${widget.hotel.countryName}',
//                       style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//                     ),
//                   ),
//                 ],
//               ),

//               SizedBox(height: 8),

//               // Address
//               Text(
//                 widget.hotel.address,
//                 style: TextStyle(fontSize: 14, color: Colors.grey[700]),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildImageSlider(List<String> images) {
//     return Stack(
//       children: [
//         // Image Slider
//         SizedBox(
//           height: 250,
//           child: PageView.builder(
//             controller: _pageController,
//             itemCount: images.length,
//             onPageChanged: _onPageChanged,
//             itemBuilder: (context, index) {
//               return _buildImageItem(images[index]);
//             },
//           ),
//         ),

//         // Page Indicator
//         if (images.length > 1)
//           Positioned(
//             bottom: 16,
//             left: 0,
//             right: 0,
//             child: _buildPageIndicator(images.length),
//           ),

//         // Image Count Badge
//         if (images.length > 1)
//           Positioned(
//             top: 16,
//             right: 16,
//             child: _buildImageCountBadge(images.length),
//           ),
//       ],
//     );
//   }

//   Widget _buildImageItem(String imageUrl) {
//     return ClipRRect(
//       child: Image.network(
//         imageUrl,
//         height: 250,
//         width: double.infinity,
//         fit: BoxFit.cover,
//         errorBuilder: (context, error, stackTrace) {
//           return Container(
//             height: 250,
//             color: Colors.grey[200],
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Icon(Icons.hotel, size: 64, color: Colors.grey),
//                 SizedBox(height: 8),
//                 Text(
//                   'hotels.image_not_available'.tr(),
//                   style: TextStyle(color: Colors.grey[600]),
//                 ),
//               ],
//             ),
//           );
//         },
//         loadingBuilder: (context, child, loadingProgress) {
//           if (loadingProgress == null) return child;
//           return Container(
//             height: 250,
//             color: Colors.grey[200],
//             child: Center(
//               child: CircularProgressIndicator(
//                 value: loadingProgress.expectedTotalBytes != null
//                     ? loadingProgress.cumulativeBytesLoaded /
//                           loadingProgress.expectedTotalBytes!
//                     : null,
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   Widget _buildPageIndicator(int totalImages) {
//     return SizedBox(
//       height: 16,
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: List.generate(totalImages, (index) {
//             return Container(
//               width: 8,
//               height: 8,
//               margin: EdgeInsets.symmetric(horizontal: 3),
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: _currentPage == index
//                     ? Colors.white
//                     : Colors.white.withValues(alpha: 0.5),
//               ),
//             );
//           }),
//         ),
//       ),
//     );
//   }

//   Widget _buildImageCountBadge(int totalImages) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: Colors.black.withValues(alpha: 0.7),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Text(
//         '${_currentPage + 1}/$totalImages',
//         style: TextStyle(
//           color: Colors.white,
//           fontSize: 14,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }

//   Widget _buildRatingBadge() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: Colors.amber,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(Icons.star, color: Colors.white, size: 16),
//           SizedBox(width: 4),
//           Text(
//             widget.hotel.hotelRating.toStringAsFixed(1),
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 14,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// lib/presentation/hotel_details/widgets/hotel_details_header.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:tayyran_app/data/models/hotel_search_model.dart';

class HotelDetailsHeader extends StatefulWidget {
  final HotelData hotel;
  final VoidCallback? onViewAllImages;

  const HotelDetailsHeader({
    super.key,
    required this.hotel,
    this.onViewAllImages,
  });

  @override
  State<HotelDetailsHeader> createState() => _HotelDetailsHeaderState();
}

class _HotelDetailsHeaderState extends State<HotelDetailsHeader> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoSlide();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoSlide() {
    final images = widget.hotel.images;
    if (images.length <= 1) return;

    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        final nextPage = (_currentPage + 1) % images.length;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
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

  @override
  Widget build(BuildContext context) {
    final images = widget.hotel.images;
    final totalImages = images.length;

    return Column(
      children: [
        // Image Gallery with Enhanced Controls
        Stack(
          children: [
            _buildImageSlider(images),

            // View All Images Button
            if (totalImages > 1 && widget.onViewAllImages != null)
              Positioned(
                top: 16,
                left: 16,
                child: GestureDetector(
                  onTap: widget.onViewAllImages,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.collections,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'View All ($totalImages)',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Image Counter
            if (totalImages > 1)
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_currentPage + 1}/$totalImages',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
        ),

        // Hotel Info
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hotel Name and Rating
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.hotel.hotelName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  _buildRatingBadge(),
                ],
              ),

              const SizedBox(height: 8),

              // Location
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${widget.hotel.cityName}, ${widget.hotel.countryName}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Address
              Text(
                widget.hotel.address,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildImageSlider(List<String> images) {
    return Stack(
      children: [
        // Image Slider
        SizedBox(
          height: 250,
          child: PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            onPageChanged: _onPageChanged,
            itemBuilder: (context, index) {
              return _buildImageItem(images[index]);
            },
          ),
        ),

        // Page Indicator
        if (images.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: _buildPageIndicator(images.length),
          ),
      ],
    );
  }

  Widget _buildImageItem(String imageUrl) {
    return Image.network(
      imageUrl,
      height: 250,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 250,
          color: Colors.grey[200],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.hotel, size: 64, color: Colors.grey),
              const SizedBox(height: 8),
              Text(
                'hotels.image_not_available'.tr(),
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        );
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          height: 250,
          color: Colors.grey[200],
          child: Center(
            child: CircularProgressIndicator(
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

  Widget _buildPageIndicator(int totalImages) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalImages, (index) {
        return Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index
                ? Colors.white
                : Colors.white.withOpacity(0.5),
          ),
        );
      }),
    );
  }

  Widget _buildRatingBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.amber,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star, color: Colors.white, size: 16),
          const SizedBox(width: 4),
          Text(
            widget.hotel.hotelRating.toStringAsFixed(1),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
