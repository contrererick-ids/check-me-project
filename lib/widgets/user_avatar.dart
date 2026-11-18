import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.radius,
    this.image,
    this.loading = false,
  });

  final double radius;
  final ImageProvider? image;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: radius,
      backgroundColor: cs.surfaceContainerHighest,
      foregroundColor: cs.onSurfaceVariant,
      backgroundImage: image,
      child: loading
          ? const CircularProgressIndicator()
          : (image == null ? Icon(Icons.person, size: radius) : null),
    );
  }
}