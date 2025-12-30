import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'package:zylix/presentation/shared/color.dart';
import 'package:zylix/presentation/widgets/widgets.dart';

class ImageGrid extends StatelessWidget {
  final List<String> items;
  final List<Uint8List?> thumbnails;
  final int loadedCount;
  final ScrollController scroll;
  final Function(int value) onTap;

  const ImageGrid({
    super.key,
    required this.items,
    required this.thumbnails,
    required this.loadedCount,
    required this.scroll,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (loadedCount / items.length * 100).round();
    return Column(
      children: [
        LinearProgressIndicator(
          value: loadedCount / items.length,
          backgroundColor: AppColor.primaryColor,
          color: AppColor.primaryColor,
        ),
        Text("$progress% cargadas ($loadedCount/${items.length})"),
        const SizedBox(height: 8),
        Expanded(
          child: GridView.builder(
            controller: scroll,
            itemCount: items.length,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 150,
              childAspectRatio: 1,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemBuilder: (context, index) {
              final bytes = thumbnails[index];
              return bytes != null && bytes.isNotEmpty
                  ? ImageCard(
                      image: bytes,
                      onTap: () {
                        onTap(index);
                      },
                    )
                  : Container(
                      alignment: Alignment.center,
                      child: index < loadedCount
                          ? const Icon(Icons.error, color: Colors.red, size: 24)
                          : const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                    );
            },
          ),
        ),
      ],
    );
  }
}
