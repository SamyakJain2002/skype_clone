import 'package:flutter/material.dart';

class ShimmeringLogo extends StatelessWidget {
  const ShimmeringLogo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 50, width: 50, child: Image.asset('assets/logo.png'));
  }
}
