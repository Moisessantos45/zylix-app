import 'dart:typed_data';
import 'package:flutter/material.dart';

class ImageCard extends StatelessWidget {
  final Uint8List image;
  final VoidCallback onTap;
  const ImageCard({super.key, required this.image, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.memory(
                image,
                fit: BoxFit.cover,
                gaplessPlayback: true,
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: Material(
              color: Colors.white.withAlpha(200),
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(Icons.close, color: Colors.red, size: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
