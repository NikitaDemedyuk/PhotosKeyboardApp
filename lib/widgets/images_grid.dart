import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../common/adaptive_image.dart';

class _ImageWidget extends StatelessWidget {
  final String id;
  final VoidCallback onTap;
  final double size;

  const _ImageWidget({
    Key? key,
    required this.onTap,
    required this.id,
    required this.size,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image(
            key: ValueKey(id),
            fit: BoxFit.cover,
            image: AdaptiveImage(
              id: id,
              width: size,
              height: size,
            ),
          ),
        ),
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(onTap: onTap),
          ),
        )
      ],
    );
  }
}

class ImagesGridWidget extends StatelessWidget {
  final Iterable<String> images;
  final double keyboardHeight;
  final ValueChanged<String> onImageTap;

  const ImagesGridWidget(
      {Key? key,
      required this.images,
      required this.keyboardHeight,
      required this.onImageTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isIos = Theme.of(context).platform == TargetPlatform.iOS;
    final imageSize = MediaQuery.of(context).size.width * 0.6;
    return Container(
      color: Colors.grey[200],
      height: keyboardHeight,
      child: CustomScrollView(
        scrollDirection: Axis.horizontal,
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(isIos
                      ? CupertinoIcons.camera
                      : Icons.camera_alt_outlined),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    isIos ? CupertinoIcons.videocam : Icons.videocam,
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    isIos
                        ? CupertinoIcons.circle_grid_3x3_fill
                        : Icons.apps_rounded,
                  ),
                ),
              ],
            ),
          ),
          SliverGrid.count(
            crossAxisCount: 2,
            crossAxisSpacing: 5,
            mainAxisSpacing: 5,
            children: images.map((e) {
              return _ImageWidget(
                onTap: () => onImageTap(e),
                id: e,
                size: imageSize,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
