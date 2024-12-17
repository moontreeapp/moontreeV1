import 'package:magic/presentation/theme/colors.dart';
import 'package:magic/presentation/theme/fonts.dart';
import 'package:magic/presentation/theme/text.dart';
import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.onPressed,
    this.onHover,
    required this.label,
    this.buttonColor = AppColors.button,
    this.textColor = AppColors.white,
    this.isDisabled = false,
    this.fontSize = 16,
    this.height = 64,
    this.fontWeight = FontWeights.semiBold,
  });

  final VoidCallback onPressed;
  final void Function(bool)? onHover;
  final String label;
  final Color buttonColor;
  final Color textColor;
  final bool isDisabled;
  final double fontSize;
  final double height;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isDisabled ? 0.5 : 1,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: buttonColor,
          fixedSize: Size(double.maxFinite, height),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28 * 100),
          ),
          shadowColor: Colors.transparent,
          overlayColor: AppColors.white.withValues(alpha: 0.12),
          padding: const EdgeInsets.symmetric(vertical: 10),
        ),
        onPressed: isDisabled ? null : onPressed,
        onHover: isDisabled ? null : onHover,
        child: Text(
          label,
          style: AppText.button1.copyWith(
            fontSize: fontSize,
            color: textColor,
            fontWeight: fontWeight,
          ),
        ),
      ),
    );
  }
}
