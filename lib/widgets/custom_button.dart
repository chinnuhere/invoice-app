import 'package:flutter/material.dart';
import '../config/app_constants.dart';

enum ButtonType {
  primary,
  secondary,
  outlined,
  text,
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType buttonType;
  final bool isLoading;
  final bool isFullWidth;
  final double? height;
  final double? width;
  final Widget? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.buttonType = ButtonType.primary,
    this.isLoading = false,
    this.isFullWidth = false,
    this.height,
    this.width,
    this.icon,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final buttonHeight = height ?? AppConstants.buttonHeight48;
    final theme = Theme.of(context);

    Widget buttonChild;
    if (isLoading) {
      buttonChild = const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    } else if (icon != null) {
      buttonChild = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon!,
          const SizedBox(width: AppConstants.spacing8),
          Text(text),
        ],
      );
    } else {
      buttonChild = Text(text);
    }

    switch (buttonType) {
      case ButtonType.primary:
        return SizedBox(
          width: isFullWidth ? double.infinity : width,
          height: buttonHeight,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor,
              foregroundColor: foregroundColor,
              elevation: AppConstants.elevation2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radius12),
              ),
            ),
            child: buttonChild,
          ),
        );

      case ButtonType.secondary:
        return SizedBox(
          width: isFullWidth ? double.infinity : width,
          height: buttonHeight,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: backgroundColor ?? theme.colorScheme.secondaryContainer,
              foregroundColor: foregroundColor ?? theme.colorScheme.onSecondaryContainer,
              elevation: AppConstants.elevation0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radius12),
              ),
            ),
            child: buttonChild,
          ),
        );

      case ButtonType.outlined:
        return SizedBox(
          width: isFullWidth ? double.infinity : width,
          height: buttonHeight,
          child: OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              foregroundColor: foregroundColor,
              side: BorderSide(
                color: backgroundColor ?? theme.colorScheme.primary,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radius12),
              ),
            ),
            child: buttonChild,
          ),
        );

      case ButtonType.text:
        return SizedBox(
          width: isFullWidth ? double.infinity : width,
          height: buttonHeight,
          child: TextButton(
            onPressed: isLoading ? null : onPressed,
            style: TextButton.styleFrom(
              foregroundColor: foregroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radius8),
              ),
            ),
            child: buttonChild,
          ),
        );
    }
  }
}
