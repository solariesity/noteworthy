import 'package:flutter/material.dart';

class NotefulCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const NotefulCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: padding,
        child: child,
      ),
    );
  }
}
