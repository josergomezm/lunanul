import 'package:flutter/material.dart';

/// Custom icon widget that can display SVG or image assets
class CustomIcon extends StatelessWidget {
  final String assetPath;
  final double? size;
  final Color? color;

  const CustomIcon({super.key, required this.assetPath, this.size, this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size ?? 24,
      height: size ?? 24,
      child: ColorFiltered(
        colorFilter: color != null
            ? ColorFilter.mode(color!, BlendMode.srcIn)
            : const ColorFilter.mode(Colors.transparent, BlendMode.multiply),
        child: Image.asset(
          assetPath,
          filterQuality: FilterQuality.high,
          isAntiAlias: true,
          fit: BoxFit.contain,
          gaplessPlayback: true,
        ),
      ),
    );
  }
}

/// Navigation bar icons with custom assets
class NavIcons {
  static const String _basePath = 'assets/icons/';

  // Home icons
  static const String homeOutlined = '${_basePath}home_outlined.png';
  static const String homeFilled = '${_basePath}home_filled.png';

  // Readings icons
  static const String readingsOutlined = '${_basePath}readings_outlined.png';
  static const String readingsFilled = '${_basePath}readings_filled.png';

  // Manual/Interpretations icons
  static const String manualOutlined = '${_basePath}manual_outlined.png';
  static const String manualFilled = '${_basePath}manual_filled.png';

  // Yourself icons
  static const String yourselfOutlined = '${_basePath}yourself_outlined.png';
  static const String yourselfFilled = '${_basePath}yourself_filled.png';

  // Friends icons
  static const String friendsOutlined = '${_basePath}friends_outlined.png';
  static const String friendsFilled = '${_basePath}friends_filled.png';
}
