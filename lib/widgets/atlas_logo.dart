import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AtlasLogo extends StatelessWidget {
  const AtlasLogo({
    super.key,
    this.size = 120,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/images/atlaslogo.svg',
      width: size,
      height: size,
    );
  }
}