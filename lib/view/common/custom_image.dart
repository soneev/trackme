import 'package:flutter/material.dart';

class CustomPngImage extends StatelessWidget {
  final String? imageName;
  final double? height;
  final double? width;
  final BoxFit? boxFit;
  final Color? color;

  const CustomPngImage(
      {super.key,
      this.imageName,
      this.height,
      this.width,
      this.boxFit,
      this.color});
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      imageName!,
      color: color,
      height: height,
      width: width,
      fit: boxFit ?? BoxFit.contain,
      isAntiAlias: true,
    );
  }
}

class CustomNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final double? height;
  final double? width;
  final BoxFit? boxFit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const CustomNetworkImage({
    super.key,
    this.imageUrl,
    this.height,
    this.width,
    this.boxFit,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return errorWidget ??
          Icon(Icons.broken_image, size: width ?? 50, color: Colors.grey);
    }

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(8),
      child: Image.network(
        imageUrl!,
        height: height,
        width: width,
        fit: boxFit ?? BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: SizedBox(
              height: 30,
              width: 30,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor:
                    AlwaysStoppedAnimation(Theme.of(context).primaryColor),
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ??
              Container(
                height: height,
                width: width,
                color: Colors.grey.shade200,
                alignment: Alignment.center,
                child: Icon(Icons.image_not_supported,
                    color: Colors.grey, size: width != null ? width! / 2 : 30),
              );
        },
      ),
    );
  }
}
