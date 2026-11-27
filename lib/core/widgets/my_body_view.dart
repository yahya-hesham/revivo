import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Standard screen body wrapper applying Revivo screen padding and SafeArea.
class MyBodyView extends StatelessWidget {
  const MyBodyView({
    super.key,
    required this.child,
    this.padding = AppConstants.paddingScreen,
    this.useSafeArea = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool useSafeArea;

  @override
  Widget build(BuildContext context) {
    final content = Padding(padding: padding, child: child);
    return useSafeArea ? SafeArea(child: content) : content;
  }
}
