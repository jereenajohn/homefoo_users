import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class AnimatedMarker extends StatefulWidget {
  final String imageUrl;
  final AnimationController controller;

  AnimatedMarker({required this.imageUrl, required this.controller});

  @override
  _AnimatedMarkerState createState() => _AnimatedMarkerState();
}

class _AnimatedMarkerState extends State<AnimatedMarker> {
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        return ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.yellow.withOpacity(widget.controller.value),
            BlendMode.srcATop,
          ),
          child: Image.network(widget.imageUrl),
        );
      },
    );
  }
}

Future<Uint8List> createMarkerImage(GlobalKey key) async {
  RenderRepaintBoundary boundary = key.currentContext!.findRenderObject() as RenderRepaintBoundary;
  ui.Image image = await boundary.toImage();
  ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}