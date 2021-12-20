import 'package:flutter/material.dart';

class NotificationIcon extends StatelessWidget {
  final IconData? icon;
  final double? size;
  final Color? color;
  final String? semanticLabel;
  final TextDirection? textDirection;
  final Color notificationColor;
  final double notificationSize;
  final bool showNotification;

  const NotificationIcon(
    this.icon, {
    Key? key,
    this.size,
    this.color,
    this.semanticLabel,
    this.textDirection,
    this.notificationColor = Colors.red,
    this.notificationSize = 8,
    this.showNotification = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final _icon = Icon(
      icon,
      key: key,
      size: size,
      color: color,
      semanticLabel: semanticLabel,
      textDirection: textDirection,
    );
    if (!showNotification) {
      return _icon;
    }
    return Stack(
      children: [
        _icon,
        Positioned(
          bottom: 0,
          left: 0,
          child: SizedBox(
            height: notificationSize,
            width: notificationSize,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(notificationSize),
                color: notificationColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
