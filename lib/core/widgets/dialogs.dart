import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../styles/colors.dart';

enum DialogType { info, success, error }

void showMyDialog(
  BuildContext context,
  String message, {
  DialogType type = DialogType.info,
}) {
  final Color backgroundColor = switch (type) {
    DialogType.success => AppColors.success,
    DialogType.error => AppColors.red,
    DialogType.info => AppColors.teal,
  };

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: AppColors.white),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(
          borderRadius: AppConstants.borderRadius12,
        ),
        margin: AppConstants.paddingAll16,
      ),
    );
}

Future<void> showLoadingDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const PopScope(
      canPop: false,
      child: Center(
        child: Card(
          child: Padding(
            padding: AppConstants.paddingAll24,
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    ),
  );
}
