import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Standardized SVG icon wrapper.
class CustomSvgPicture extends StatelessWidget {
  const CustomSvgPicture({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.color,
    this.fit = BoxFit.contain,
    this.semanticsLabel,
  });

  final String assetPath;
  final double? width;
  final double? height;
  final Color? color;
  final BoxFit fit;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      semanticsLabel: semanticsLabel,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
    );
  }
}
