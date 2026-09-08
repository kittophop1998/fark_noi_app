import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_shape.dart';
import '../../core/theme/app_typography.dart';

/// A labelled field.
///
/// One height (52px) and one radius (12px) across the product, so a form reads
/// as a stack of equal rows rather than as a pile of controls.
///
/// **Error is never a red border alone** — the message under the field is the
/// signal, and the border is what draws the eye to it. A colour on its own is
/// not a message a colour-blind reader can act on.
///
/// The text is 16px and stays 16px: Thai loses legibility a step earlier than
/// Latin, and nothing in the product is under 12px.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.helper,
    this.error,
    this.controller,
    this.initialValue,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.prefixIcon,
    this.suffix,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.enabled = true,
    this.autofocus = false,
    this.readOnly = false,
    this.onTap,
  });

  final String? label;
  final String? hint;

  /// One quiet line under the field, always visible — a format, a rule.
  final String? helper;

  /// The message that replaces [helper] when the value is wrong.
  final String? error;

  final TextEditingController? controller;
  final String? initialValue;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final IconData? prefixIcon;
  final Widget? suffix;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool enabled;
  final bool autofocus;

  /// A field that opens a picker instead of a keyboard — a date, a place.
  final bool readOnly;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final hasError = error != null && error!.isNotEmpty;
    final multiline = (maxLines ?? 1) > 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: AppText.label.copyWith(color: AppColors.text),
          ),
          const SizedBox(height: AppSpace.x2),
        ],
        TextFormField(
          controller: controller,
          initialValue: controller == null ? initialValue : null,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          validator: validator,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          maxLines: obscureText ? 1 : maxLines,
          minLines: minLines,
          maxLength: maxLength,
          enabled: enabled,
          autofocus: autofocus,
          readOnly: readOnly,
          onTap: onTap,
          cursorColor: AppColors.primary,
          style: AppText.body.copyWith(
            color: enabled ? AppColors.text : AppColors.disabled,
          ),
          decoration: InputDecoration(
            hintText: hint,
            counterText: '',
            filled: true,
            fillColor:
                enabled ? AppColors.surface : AppColors.surfaceDisabled,
            prefixIcon: prefixIcon == null
                ? null
                : Icon(
                    prefixIcon,
                    size: AppMetrics.icon,
                    color: AppColors.faint,
                  ),
            suffixIcon: suffix == null
                ? null
                : Padding(
                    padding: const EdgeInsets.only(right: AppSpace.x2),
                    child: suffix,
                  ),
            suffixIconConstraints: const BoxConstraints(minWidth: 0),
            // A single-line field is a fixed 52px; a textarea grows from its
            // own padding instead, because a fixed height on a multiline field
            // is a scroll trap.
            constraints: multiline
                ? null
                : const BoxConstraints(minHeight: AppMetrics.fieldHeight),
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpace.x4,
              vertical: multiline ? AppSpace.x3 : AppSpace.x2 + 6,
            ),
            enabledBorder: _border(
              hasError ? AppColors.errorBorder : AppColors.border,
            ),
            focusedBorder: _border(
              hasError ? AppColors.error : AppColors.focus,
              width: 2,
            ),
            disabledBorder: _border(AppColors.borderSubtle),
            // The field's own error text is suppressed — the line below is
            // drawn by this widget so it shares the helper's slot and the row
            // does not jump by a line height when a value goes bad.
            errorStyle: const TextStyle(height: 0, fontSize: 0),
          ),
        ),
        if (hasError || (helper != null && helper!.isNotEmpty)) ...[
          const SizedBox(height: AppSpace.x1 + 2),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasError) ...[
                const Icon(
                  Icons.error_outline_rounded,
                  size: 14,
                  color: AppColors.error,
                ),
                const SizedBox(width: AppSpace.x1),
              ],
              Expanded(
                child: Text(
                  hasError ? error! : helper!,
                  style: AppText.caption.copyWith(
                    color:
                        hasError ? AppColors.errorStrong : AppColors.faint,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  OutlineInputBorder _border(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: AppRadius.brMd,
      borderSide: BorderSide(color: color, width: width),
    );
  }
}

/// The shell of a field, for a control that is not a `TextField` — a picker
/// row, a store selector, a read-only value that opens a sheet.
///
/// Exported so those controls do not each redraw the 52px / 12px box and drift
/// a pixel apart from the real one.
class AppFieldShell extends StatelessWidget {
  const AppFieldShell({
    super.key,
    required this.child,
    this.label,
    this.onTap,
    this.hasError = false,
    this.height = AppMetrics.fieldHeight,
  });

  final Widget child;
  final String? label;
  final VoidCallback? onTap;
  final bool hasError;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label!, style: AppText.label.copyWith(color: AppColors.text)),
          const SizedBox(height: AppSpace.x2),
        ],
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: height,
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.x4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.brMd,
              border: Border.all(
                color: hasError ? AppColors.errorBorder : AppColors.border,
              ),
            ),
            child: Row(children: [Expanded(child: child)]),
          ),
        ),
      ],
    );
  }
}
