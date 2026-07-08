import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AtlasText extends StatelessWidget {
  const AtlasText({
    super.key,
    this.width = 180,
  });

  final double width;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/images/text.svg',
      width: width,
    );
  }
}