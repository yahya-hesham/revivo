import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../styles/colors.dart';

/// Card-style stacked text field matching Revivo Figma `Field` (`3:14`, `3:17`).
/// Renders a rounded-20 surface container with the caption label inside the top
/// and the editable input directly beneath it.
class CustomTextFormField extends StatefulWidget {
  const CustomTextFormField({
    super.key,
    required this.label,
    this.controller,
    this.hintText,
    this.helperText,
    this.errorText,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.isPassword = false,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.prefixIcon,
    this.suffixIcon,
    this.onTap,
  });

  final String label;
  final TextEditingController? controller;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final bool isPassword;
  final bool enabled;
  final bool readOnly;
  final int maxLines;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final VoidCallback? onTap;

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  late bool _obscureText;
  late final FocusNode _focusNode;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
    _focusNode = FocusNode()
      ..addListener(() {
        if (mounted) {
          setState(() => _hasFocus = _focusNode.hasFocus);
        }
      });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return FormField<String>(
      initialValue: widget.controller?.text ?? '',
      validator: (value) => widget.validator?.call(
        widget.controller?.text ?? value,
      ),
      builder: (fieldState) {
        final effectiveError = widget.errorText ?? fieldState.errorText;
        final hasError = effectiveError != null && effectiveError.isNotEmpty;

        final borderColor = hasError
            ? AppColors.red
            : _hasFocus
                ? scheme.primary
                : scheme.outline;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: () {
                if (widget.onTap != null) {
                  widget.onTap!();
                } else if (widget.enabled && !widget.readOnly) {
                  _focusNode.requestFocus();
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: double.infinity,
                padding: const EdgeInsetsDirectional.fromSTEB(
                  AppConstants.space16,
                  AppConstants.space12,
                  AppConstants.space16,
                  AppConstants.space12,
                ),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: AppConstants.borderRadius20,
                  border: Border.all(
                    color: borderColor,
                    width: _hasFocus || hasError ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (widget.prefixIcon != null) ...[
                      widget.prefixIcon!,
                      const SizedBox(width: AppConstants.space8),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.label,
                            style: textTheme.bodySmall?.copyWith(
                              color: hasError
                                  ? AppColors.red
                                  : scheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: AppConstants.space4),
                          TextField(
                            controller: widget.controller,
                            focusNode: _focusNode,
                            onChanged: (value) {
                              fieldState.didChange(value);
                              widget.onChanged?.call(value);
                            },
                            onSubmitted: widget.onFieldSubmitted,
                            keyboardType: widget.keyboardType,
                            textInputAction: widget.textInputAction,
                            autofillHints: widget.autofillHints,
                            obscureText: _obscureText,
                            enabled: widget.enabled,
                            readOnly: widget.readOnly,
                            maxLines: widget.isPassword ? 1 : widget.maxLines,
                            onTap: widget.onTap,
                            style: textTheme.bodyLarge?.copyWith(
                              color: scheme.onSurface,
                            ),
                            decoration: InputDecoration(
                              isDense: true,
                              filled: false,
                              contentPadding: EdgeInsets.zero,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              hintText: widget.hintText,
                              hintStyle: textTheme.bodyLarge?.copyWith(
                                color: scheme.onSurfaceVariant.withValues(
                                  alpha: 0.6,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.isPassword)
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: AppConstants.touchTargetSize,
                          minHeight: AppConstants.touchTargetSize,
                        ),
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: scheme.onSurfaceVariant,
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => _obscureText = !_obscureText),
                      )
                    else if (widget.suffixIcon != null)
                      widget.suffixIcon!,
                  ],
                ),
              ),
            ),
            if (hasError) ...[
              const SizedBox(height: AppConstants.space4),
              Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: AppConstants.space8,
                ),
                child: Text(
                  effectiveError,
                  style: textTheme.bodySmall?.copyWith(color: AppColors.red),
                ),
              ),
            ] else if (widget.helperText != null) ...[
              const SizedBox(height: AppConstants.space4),
              Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: AppConstants.space8,
                ),
                child: Text(
                  widget.helperText!,
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
