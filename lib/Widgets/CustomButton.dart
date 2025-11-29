import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String? text;
  final IconData? startIcon;
  final IconData? endIcon;

  final Color? textColor;
  final Color? startIconColor;
  final Color? endIconColor;

  final Color? backgroundColor;
  final double? cornerRadius;

  final EdgeInsetsGeometry? padding;
  final double? height;
  final double? width;

  final VoidCallback onPressed;

  const CustomButton({
    super.key,
    this.text,
    this.startIcon,
    this.endIcon,
    this.textColor,
    this.startIconColor,
    this.endIconColor,
    this.backgroundColor,
    this.cornerRadius,
    this.padding,
    this.height,
    this.width,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? 42,
      width: width,
      padding: EdgeInsets.zero,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? Colors.blue,
          foregroundColor: textColor ?? Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(cornerRadius ?? 10),
          ),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          elevation: 0,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (startIcon != null)
              Icon(startIcon, size: 18, color: startIconColor ?? Colors.white),

            if (startIcon != null && text != null) const SizedBox(width: 6),

            if (text != null)
              Text(
                text!,
                style: TextStyle(
                  color: textColor ?? Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),

            if (text != null && endIcon != null) const SizedBox(width: 6),

            if (endIcon != null)
              Icon(endIcon, size: 18, color: endIconColor ?? Colors.white),
          ],
        ),
      ),
    );
  }
}
