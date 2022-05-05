import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'constants.dart';

class AdaptiveImage extends ImageProvider<AdaptiveImage> {
  final String id;
  final double width;
  final double height;

  AdaptiveImage({required this.id, required this.width, required this.height});

  @override
  ImageStreamCompleter load(AdaptiveImage key, DecoderCallback decode) {
    // TODO: implement load
    return MultiFrameImageStreamCompleter(
        codec: _loadAsync(key, decode),
        scale: 1.0,
        debugLabel: id,
        informationCollector: () sync* {
          yield ErrorDescription('Id: $id');
        });
  }

  @override
  Future<AdaptiveImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<AdaptiveImage>(this);
  }

  Future<Codec> _loadAsync(AdaptiveImage key, DecoderCallback decode) async {
    assert(key == this);

    // 1
    final bytes = await methodChannel.invokeMethod<Uint8List>(
        'fetchImage', {'id': id, 'width': width, 'height': height});

    // 2
    if (bytes == null || bytes.lengthInBytes == 0) {
      PaintingBinding.instance!.imageCache!.evict(key);
      throw StateError("Image for $id couldn't be loaded");
    }
    return decode(bytes);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is AdaptiveImage &&
              runtimeType == other.runtimeType &&
              id == other.id &&
              width == other.width &&
              height == other.height;

  @override
  String toString() {
    return '${objectRuntimeType(this, 'AdaptiveImage')}('
        '"$id", width: $width, height: $height)';
  }

  @override
  int get hashCode => id.hashCode ^ width.hashCode ^ height.hashCode;
}