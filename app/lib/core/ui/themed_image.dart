import 'package:flutter/material.dart';

String themedImagePath(BuildContext context, String baseName) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return 'assets/images/$baseName-${isDark ? 'dark' : 'light'}.png';
}

class ThemedImage extends StatelessWidget {
  const ThemedImage({
    super.key,
    required this.baseName,
    this.width,
    this.height,
    this.fit,
  });
  final String baseName;
  final double? width;
  final double? height;
  final BoxFit? fit;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      themedImagePath(context, baseName),
      width: width,
      height: height,
      fit: fit,
    );
  }
}
