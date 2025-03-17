import 'dart:async';
import 'package:flutter/material.dart';

class AnimatedMarkerIcon extends StatefulWidget {
  final String imageUrl;
  final double width;
  final double height;

  const AnimatedMarkerIcon({
    Key? key,
    required this.imageUrl,
    this.width = 100,
    this.height = 100,
  }) : super(key: key);

  @override
  _AnimatedMarkerIconState createState() => _AnimatedMarkerIconState();
}

class _AnimatedMarkerIconState extends State<AnimatedMarkerIcon> {
  bool _isImageVisible = true;

  @override
  void initState() {
    super.initState();
    _startImageFadeAnimation();
  }

  void _startImageFadeAnimation() {
    Timer.periodic(Duration(seconds: 3), (timer) {
      setState(() {
        _isImageVisible = !_isImageVisible;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _isImageVisible ? 1.0 : 0.0,
      duration: Duration(seconds: 1),
      child: Image.network(
        widget.imageUrl,
        width: widget.width,
        height: widget.height,
        fit: BoxFit.cover,
      ),
    );
  }
}