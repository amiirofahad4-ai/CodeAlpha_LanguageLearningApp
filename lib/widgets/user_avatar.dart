import 'package:flutter/material.dart';

import '../core/app_colors.dart';
import '../models/user.dart';

/// Circle avatar showing the user's photo or initials on a gradient.
class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.user, this.radius = 24});

  final AppUser? user;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final url = user?.avatarUrl;
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.primaryGradient,
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: url != null
          ? Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _initials(),
            )
          : _initials(),
    );
  }

  Widget _initials() => Text(
    user?.initials ?? '?',
    style: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.w700,
      fontSize: radius * 0.75,
    ),
  );
}
