import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../common/adaptive_image.dart';



class _ImageWidget extends StatelessWidget {
  final String id;
  final VoidCallback onRemoved;
  final double size;

  const _ImageWidget({
    Key? key,
    required this.onRemoved,
    required this.id,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isIos = Theme.of(context).platform == TargetPlatform.iOS;
    final imageSize = size - 15;
    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 10),
      child: SizedBox(
        height: size,
        width: size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: 15,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image(
                  width: imageSize,
                  height: imageSize,
                  fit: BoxFit.cover,
                  image: AdaptiveImage(
                    id: id,
                    width: imageSize,
                    height: imageSize,
                  ),
                ),
              ),
            ),
            Positioned(
              top: -10,
              right: -10,
              child: IconButton(
                onPressed: onRemoved,
                icon: Icon(
                  isIos ? CupertinoIcons.multiply_circle_fill : Icons.cancel,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ImagesListWidget extends StatelessWidget {
  final Set<String> images;
  final ValueChanged<String> onRemoved;
  final ScrollController controller;

  const ImagesListWidget({
    Key? key,
    required this.images,
    required this.onRemoved,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final itemSize = MediaQuery.of(context).size.width * 0.21;
    return SizedBox(
      height: images.isEmpty ? 0 : itemSize,
      child: ListView.builder(
        controller: controller,
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemBuilder: (c, i) {
          final id = images.elementAt(i);
          return _ImageWidget(
            key: ValueKey(id),
            onRemoved: () => onRemoved(id),
            id: id,
            size: itemSize,
          );
        },
      ),
    );
  }
}
