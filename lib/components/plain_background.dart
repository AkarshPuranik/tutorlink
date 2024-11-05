import 'package:flutter/material.dart';

class PlainBackground extends StatelessWidget {
  const PlainBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Image.asset(
        "assets/plain_bg.png",
        fit: BoxFit.cover,
      ),
    );
  }
}
