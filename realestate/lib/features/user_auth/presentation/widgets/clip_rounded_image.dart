import 'package:flutter/material.dart';
import 'clip_rounded_network_image.dart';

class ClipRoundedImage extends StatelessWidget {
  final String? url;
  final double height;

  const ClipRoundedImage({super.key, required this.url, required this.height});

  @override
  Widget build(BuildContext context) {
    return ClipRoundedNetworkImage(
      imageUrl: url ?? '',
      height: height,
      fit: BoxFit.cover,
    );
  }
}
