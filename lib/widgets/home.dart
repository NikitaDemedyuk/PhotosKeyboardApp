// Copyright (c) 2022 Razeware LLC
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
// distribute, sublicense, create a derivative work, and/or sell copies of the
// Software in any work that is designed, intended, or marketed for pedagogical
// or instructional purposes related to programming, coding, application
// development, or information technology.  Permission for such use, copying,
// modification, merger, publication, distribution, sublicensing, creation of
// derivative works, or sale is expressly withheld.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import 'package:flutter/material.dart';
import '../common/common_scaffold.dart';
import '../common/constants.dart';
import 'bottom_container.dart';
import 'images_grid.dart';
import 'images_list.dart';
import 'dart:math' as math;

class HomeWidget extends StatefulWidget {
  final Widget messagesWidget;

  const HomeWidget({Key? key, required this.messagesWidget}) : super(key: key);

  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends State<HomeWidget> {
  Iterable<String> images = <String>[];
  var showGrid = false;
  var gridHeight = 0.0;
  final selectedImages = <String>{};
  final focus = FocusNode();
  final textController = TextEditingController();
  final selectedImagesController = ScrollController();

  @override
  void initState() {
    focus.addListener(() => setState(() {}));
    textController.addListener(() => setState(() {}));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final bottomHeight = getBottomHeight();
    return CommonScaffold(
      title: MyStrings.title,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          setState(() {
            showGrid = false;
            focus.unfocus();
          });
        },
        child: widget.messagesWidget,
      ),
      bottomNav: SafeArea(
        bottom: true,
        child: BottomContainer(
          keyboardHeight: bottomHeight,
          focus: focus,
          showIcons: focus.hasFocus || showGrid,
          onPhotosClick: togglePhotos,
          controller: textController,
          showGrid: showGrid,
          enableSend:
              selectedImages.isNotEmpty || textController.text.isNotEmpty,
          grid: ImagesGridWidget(
            images: images,
            keyboardHeight: bottomHeight,
            onImageTap: onImageTap,
          ),
          listWidget: ImagesListWidget(
            images: selectedImages,
            onRemoved: onImageRemoved,
            controller: selectedImagesController,
          ),
        ),
      ),
    );
  }

  void togglePhotos() {
    if (showGrid) {
      setState(() {
        showGrid = false;
        focus.requestFocus();
      });
    } else {
      getAllPhotos();
    }
  }

  void onImageRemoved(String id) {
    setState(() => selectedImages.remove(id));
  }

  void onImageTap(String id) {
    setState(() => selectedImages.add(id));
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      final pos = selectedImagesController.position.maxScrollExtent;
      selectedImagesController.jumpTo(pos);
    });
  }
  
  void getAllPhotos() async {
    // 1
    gridHeight = getKeyboardHeight();
    // 2
    final results = await methodChannel.invokeMethod<List>('getPhotos', 1000);
    if (results != null && results.isNotEmpty) {
      setState(() {
        images = results.cast<String>();
        // 3
        showGrid = images.isNotEmpty;
        // 4
        focus.unfocus();
      });
    }
  }

  double getKeyboardHeight() {
    return MediaQuery.of(context).viewInsets.bottom;
  }

  double getBottomHeight() {
    final minHeight = MediaQuery.of(context).size.height * 0.35;
    return showGrid ? math.max(gridHeight, minHeight) : getKeyboardHeight();
  }

  @override
  void dispose() {
    focus.dispose();
    textController.dispose();
    selectedImagesController.dispose();
    super.dispose();
  }
}
