import 'package:flutter/material.dart';

import '../../theme/app_tokens.dart';
import 'buttons.dart';

/// Opens a rounded bottom sheet with the design's surface styling and a grab
/// handle. Returns whatever the sheet pops with.
Future<T?> showAppSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool isScrollControlled = true,
}) {
  final t = context.tokens;
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: t.surface,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 42,
            height: 5,
            decoration: BoxDecoration(
              color: t.text2.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: builder(ctx),
            ),
          ),
        ],
      ),
    ),
  );
}

/// A themed confirm dialog. Returns true when confirmed.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
  bool danger = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      final t = ctx.tokens;
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 36),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 10),
              Text(
                message,
                style: TextStyle(fontSize: 14, height: 1.5, color: t.text2),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: AppButton.ghost(
                      label: cancelLabel,
                      block: true,
                      onPressed: () => Navigator.of(ctx).pop(false),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: danger
                        ? AppButton.danger(
                            label: confirmLabel,
                            block: true,
                            onPressed: () => Navigator.of(ctx).pop(true),
                          )
                        : AppButton.primary(
                            label: confirmLabel,
                            block: true,
                            onPressed: () => Navigator.of(ctx).pop(true),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
  return result ?? false;
}

/// Floating toast (design `.toast`) via the ScaffoldMessenger.
void showAppToast(
  BuildContext context,
  String message, {
  bool success = true,
  IconData? icon,
}) {
  final t = context.tokens;
  final accent = success ? t.paid : t.due;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              icon ?? (success ? Icons.check_circle_rounded : Icons.error_rounded),
              color: accent,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: t.isDark ? t.text : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
}
