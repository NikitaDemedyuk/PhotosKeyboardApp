import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


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
          // TODO: Add Sliver grid here.
        ],
      ),
    );
  }
}
