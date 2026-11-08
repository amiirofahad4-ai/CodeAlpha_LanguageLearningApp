import 'package:flutter/material.dart';

import '../core/constants.dart';

/// Centers content and caps its width so layouts look good on large
/// phones and tablets as well as small phones.
class ResponsiveCenter extends StatelessWidget {
  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth = AppConstants.maxContentWidth,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// Grid column count that adapts to the available width.
int responsiveColumns(double width, {double minTileWidth = 160}) =>
    (width / minTileWidth).floor().clamp(2, 4);
