
import 'package:flutter/material.dart';

class ButtonWithTheme extends StatelessWidget {
  final IconData icon;
  final double iconSize;
  final VoidCallback onPressed;
  final Color boxColor;
  final bool isBorder;
  final Color? borderColor;
  final Color? iconColor;
  final double degreeOfRoundness;

  const ButtonWithTheme({
    required this.icon,
    required this.onPressed,
    required this.boxColor,
    this.isBorder = false,
    this.iconSize = 24.0,
    this.borderColor,
    this.iconColor,
    this.degreeOfRoundness = 16.0,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      style: ButtonStyle(
        fixedSize: MaterialStateProperty.all<Size>(Size(iconSize, iconSize)),
        backgroundColor:
        MaterialStateProperty.all<Color>(boxColor), // 박스 색상
        padding: MaterialStateProperty.all<EdgeInsets>(
            EdgeInsets.zero), // 패딩 설정
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(degreeOfRoundness), // 둥근 모서리 설정
            side: isBorder ? BorderSide(color: borderColor ?? Colors.grey.shade400, width: 2.0) : BorderSide.none,
          ),
        ),
      ),
      icon: Icon(icon,
          size: 24.0, color: iconColor ?? Colors.grey.shade400), // 연필 아이콘
      onPressed: onPressed,
    );
  }
}