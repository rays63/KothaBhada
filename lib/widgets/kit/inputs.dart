import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_tokens.dart';

/// Small field label (design `.lbl`).
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: t.text2,
        ),
      ),
    );
  }
}

/// Labelled text field (design `.field` + `.input`).
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffix,
    this.maxLines = 1,
    this.inputFormatters,
    this.onChanged,
    this.validator,
    this.textInputAction,
    this.enabled = true,
  });

  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffix;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final TextInputAction? textInputAction;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final fill = t.isDark ? t.surface : t.surface2;
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.rInput),
          borderSide: BorderSide(color: c, width: w),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) FieldLabel(label!),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: obscureText ? 1 : maxLines,
          inputFormatters: inputFormatters,
          onChanged: onChanged,
          validator: validator,
          enabled: enabled,
          textInputAction: textInputAction,
          style: TextStyle(fontSize: 14, color: t.text),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: t.text2, fontSize: 14),
            filled: true,
            fillColor: fill,
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            prefixIcon: prefixIcon == null
                ? null
                : Icon(prefixIcon, size: 18, color: t.text2),
            suffixIcon: suffix,
            border: border(t.line),
            enabledBorder: border(t.line),
            focusedBorder: border(t.brand2, 1.4),
            errorBorder: border(t.due),
            focusedErrorBorder: border(t.due, 1.4),
          ),
        ),
      ],
    );
  }
}

/// A read-only field that opens a date picker (design `DateField`).
class AppDateField extends StatelessWidget {
  const AppDateField({
    super.key,
    this.label,
    required this.value,
    required this.onChanged,
    this.firstDate,
    this.lastDate,
  });

  final String? label;
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final text = value == null
        ? 'Select date'
        : '${value!.year}-${value!.month.toString().padLeft(2, '0')}-${value!.day.toString().padLeft(2, '0')}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) FieldLabel(label!),
        GestureDetector(
          onTap: () async {
            final now = DateTime.now();
            final picked = await showDatePicker(
              context: context,
              initialDate: value ?? now,
              firstDate: firstDate ?? DateTime(now.year - 5),
              lastDate: lastDate ?? DateTime(now.year + 5),
            );
            if (picked != null) onChanged(picked);
          },
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: t.isDark ? t.surface : t.surface2,
              borderRadius: BorderRadius.circular(AppTokens.rInput),
              border: Border.all(color: t.line),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_rounded, size: 16, color: t.text2),
                const SizedBox(width: 10),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 14,
                    color: value == null ? t.text2 : t.text,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Pill segmented control (design `.seg`).
class SegmentedControl<T> extends StatelessWidget {
  const SegmentedControl({
    super.key,
    required this.segments,
    required this.value,
    required this.onChanged,
  });

  final Map<T, String> segments;
  final T value;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: t.isDark ? t.surface : t.surface2,
        borderRadius: BorderRadius.circular(AppTokens.rPill),
        border: Border.all(color: t.line),
      ),
      child: Row(
        children: segments.entries.map((e) {
          final selected = e.key == value;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(e.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 9),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: selected ? t.brandGradient : null,
                  borderRadius: BorderRadius.circular(AppTokens.rPill),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: t.brand2.withValues(alpha: 0.30),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  e.value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : t.text2,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// Gradient pill toggle (design `.toggle`).
class AppToggle extends StatelessWidget {
  const AppToggle({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 46,
        height: 27,
        padding: const EdgeInsets.all(3),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        decoration: BoxDecoration(
          gradient: value ? t.brandGradient : null,
          color: value ? null : t.text2.withValues(alpha: 0.32),
          borderRadius: BorderRadius.circular(AppTokens.rPill),
        ),
        child: Container(
          width: 21,
          height: 21,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Color(0x33000000), blurRadius: 4, offset: Offset(0, 1)),
            ],
          ),
        ),
      ),
    );
  }
}
