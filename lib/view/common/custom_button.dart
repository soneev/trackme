import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    this.height,
    this.width,
    this.color,
    this.text,
    this.onPressed,
    this.textColor,
    this.child,
    this.isGradient = false,
  });

  final double? width, height;
  final Color? color, textColor;
  final String? text;
  final Function()? onPressed;
  final Widget? child;
  final bool isGradient;

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Define gradient colors for light and dark themes
    final List<Color> lightGradient = [
      const Color(0xFF6D0EB5),
      const Color(0xFF4059F1),
    ];

    final List<Color> darkGradient = [
      const Color(0xFF3E0066),
      const Color(0xFF1B1F3B),
    ];

    final gradient = LinearGradient(
      colors: isDarkMode ? darkGradient : lightGradient,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final buttonChild = child ??
        Text(
          text ?? '',
          style: Theme.of(context)
              .textTheme
              .bodyMedium!
              .copyWith(color: textColor ?? Colors.white),
        );

    return Container(
      width: width ?? double.infinity,
      height: height ?? 45,
      decoration: BoxDecoration(
        color: isGradient ? null : (color ?? Colors.black),
        gradient: isGradient ? gradient : null,
        borderRadius: BorderRadius.circular(10),
      ),
      child: MaterialButton(
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        height: height ?? 45,
        minWidth: width ?? double.infinity,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        color: Colors.transparent,
        elevation: 0,
        child: buttonChild,
      ),
    );
  }
}
