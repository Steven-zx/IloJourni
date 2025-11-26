import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PlaceholderImage extends StatelessWidget {
  const PlaceholderImage({
    super.key,
    required this.height,
    required this.width,
    required this.label,
    this.color,
    this.borderRadius,
  });

  final double height;
  final double width;
  final String label;
  final Color? color;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: color ?? AppTheme.lightGrey,
        borderRadius: borderRadius,
      ),
      child: Center(
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xB3FFFFFF),
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}
