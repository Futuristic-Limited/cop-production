import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class BannerCarousel extends StatelessWidget {
  const BannerCarousel({super.key});

  final List<String> bannerImages = const [
    'assets/community_banner.jpg',
    'assets/community_banner2.jpg',
    'assets/community_banner3.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: CarouselSlider(
        options: CarouselOptions(
          autoPlay: true,
          enlargeCenterPage: true,
          viewportFraction: 1.0,
          aspectRatio: 16 / 9,
        ),
        items:
            bannerImages.map((imagePath) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              );
            }).toList(),
      ),
    );
  }
}
