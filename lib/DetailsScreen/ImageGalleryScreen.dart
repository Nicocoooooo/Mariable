import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageGalleryScreen extends StatefulWidget {
  final String mainImageUrl;
  final List<String> additionalImages;

  const ImageGalleryScreen({
    super.key, 
    required this.mainImageUrl,
    required this.additionalImages,
  });

  @override
  State<ImageGalleryScreen> createState() => _ImageGalleryScreenState();
}

class _ImageGalleryScreenState extends State<ImageGalleryScreen> {
  late final List<String> _allImages;
  
  @override
  void initState() {
    super.initState();
    // Combine main image with additional images
    _allImages = [widget.mainImageUrl, ...widget.additionalImages];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Navigation bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                ],
              ),
            ),
            
            // Image gallery
            Expanded(
              child: CustomScrollView(
                slivers: [
                  // Full width main image
                  SliverToBoxAdapter(
                    child: _buildMainImage(_allImages[0]),
                  ),
                  
                  // Grid of additional images
                  SliverPadding(
                    padding: const EdgeInsets.only(top: 3),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.0,
                        crossAxisSpacing: 3,
                        mainAxisSpacing: 3,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          // Skip the main image which is already displayed
                          final imageIndex = index + 1;
                          if (imageIndex < _allImages.length) {
                            return _buildGridImage(_allImages[imageIndex]);
                          }
                          return null;
                        },
                        childCount: _allImages.length - 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainImage(String imageUrl) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      height: 380,
      width: double.infinity,
      fit: BoxFit.cover,
      placeholder: (context, url) => Container(
        color: Colors.grey[300],
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[300],
        child: const Icon(Icons.error),
      ),
    );
  }

  Widget _buildGridImage(String imageUrl) {
    return GestureDetector(
      onTap: () {
        // You could implement a full-screen image viewer here
      },
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[300],
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[300],
          child: const Icon(Icons.error),
        ),
      ),
    );
  }
}