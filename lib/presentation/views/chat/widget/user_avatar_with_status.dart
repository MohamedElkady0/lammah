import 'package:flutter/material.dart';

class UserAvatarWithStatus extends StatelessWidget {
  final String image;
  final bool isOnline;
  final double radius;

  const UserAvatarWithStatus({
    super.key,
    required this.image,
    required this.isOnline,
    this.radius = 26,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundImage: image.isNotEmpty ? NetworkImage(image) : null,
          child: image.isEmpty ? Icon(Icons.person, size: radius) : null,
        ),
        if (isOnline)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }
}
