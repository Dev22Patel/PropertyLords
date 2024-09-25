import 'package:flutter/material.dart';

class ClipRoundedNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double height;
  final BoxFit fit;

  const ClipRoundedNetworkImage({
    super.key,
    required this.imageUrl,
    required this.height,
    required this.fit,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: Image.network(
        imageUrl,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Icon(
              Icons.error,
              color: Colors.grey[400],
              size: 48.0,
            ),
          );
        },
      ),
    );
  }
}
