import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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
    );
  }
}
