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

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class BottomContainer extends StatelessWidget {
  final Widget grid;
  final Widget listWidget;
  final double keyboardHeight;
  final FocusNode focus;
  final bool showIcons;
  final bool showGrid;
  final VoidCallback onPhotosClick;
  final TextEditingController controller;
  final bool enableSend;

  const BottomContainer(
      {Key? key,
      required this.grid,
      required this.listWidget,
      required this.keyboardHeight,
      required this.focus,
      required this.showIcons,
      required this.showGrid,
      required this.onPhotosClick,
      required this.controller,
      required this.enableSend})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isIos = Theme.of(context).platform == TargetPlatform.iOS;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(color: Colors.grey),
        Form(
          child: TextFormField(
            controller: controller,
            focusNode: focus,
            autofocus: true,
            decoration: const InputDecoration(
                hintText: 'Jot something down',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 15)),
            cursorColor: Theme.of(context).textTheme.subtitle1?.color,
            textCapitalization: TextCapitalization.sentences,
          ),
        ),
        const SizedBox(height: 5),
        listWidget,
        const SizedBox(height: 10),
        if (showIcons)
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              const SizedBox(width: 48),
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: onPhotosClick,
                      color: showGrid ? Colors.blue[400] : null,
                      icon: Icon(isIos
                          ? CupertinoIcons.photo_on_rectangle
                          : Icons.collections),
                    ),
                    const SizedBox(width: 5),
                    IconButton(
                        onPressed: () {},
                        icon: Icon(isIos
                            ? CupertinoIcons.camera
                            : Icons.camera_alt_outlined)),
                  ],
                ),
              ),
              IconButton(
                onPressed: enableSend ? () {} : null,
                icon: const Icon(Icons.send),
                color: Colors.blue[400],
              )
            ],
          ),
        if (showGrid) grid,
        if (showIcons && !showGrid) SizedBox(height: keyboardHeight)
      ],
    );
  }
}
