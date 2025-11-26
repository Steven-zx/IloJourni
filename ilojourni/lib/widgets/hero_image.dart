import 'package:flutter/material.dart';

/// Displays a rounded hero image with graceful fallback if asset missing.
class RoundedHeroImage extends StatelessWidget {
  const RoundedHeroImage({super.key, required this.assetPath, this.height = 420, this.borderRadius = 28});

  final String assetPath;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.asset(
        assetPath,
        height: height,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Container(
            height: height,
            width: double.infinity,
            color: const Color(0xFFCCE6FF),
            alignment: Alignment.center,
            child: const Icon(Icons.image_not_supported_outlined, size: 48, color: Colors.white),
          );
        },
      ),
    );
  }
}
