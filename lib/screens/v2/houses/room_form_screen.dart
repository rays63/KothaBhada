import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n_ext.dart';
import '../../../data/models/models.dart';
import '../../../data/providers.dart';
import '../../../widgets/kit/kit.dart';
import '../widgets/screen_header.dart';

/// Add / Edit Room (design screen 12).
class RoomFormScreen extends ConsumerStatefulWidget {
  const RoomFormScreen({super.key, required this.houseId, this.room});

  final String houseId;
  final Room? room;

  @override
  ConsumerState<RoomFormScreen> createState() => _RoomFormScreenState();
}

class _RoomFormScreenState extends ConsumerState<RoomFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _number;
  late final TextEditingController _rent;
  bool _saving = false;

  bool get _isEdit => widget.room != null;

  @override
  void initState() {
    super.initState();
    _number = TextEditingController(text: widget.room?.roomNumber ?? '');
    _rent = TextEditingController(
      text: widget.room == null
          ? ''
          : widget.room!.monthlyRent.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _number.dispose();
    _rent.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await ref.read(portfolioProvider.notifier).saveRoom(
          id: widget.room?.id,
          houseId: widget.houseId,
          roomNumber: _number.text.trim(),
          monthlyRent: double.tryParse(_rent.text.trim()) ?? 0,
        );
    if (!mounted) return;
    Navigator.of(context).pop();
    showAppToast(
        context, _isEdit ? context.l10n.roomUpdated : context.l10n.roomAdded);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final l = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ScreenHeader(title: _isEdit ? l.roomEdit : l.roomAdd),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
                  children: [
                    AppTextField(
                      label: l.roomNumberLabel,
                      hint: l.roomNumberHint,
                      controller: _number,
                      textInputAction: TextInputAction.next,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? l.commonRequired
                          : null,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: l.roomRentLabel,
                      hint: l.roomRentHint,
                      controller: _rent,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      validator: (v) {
                        final d = double.tryParse((v ?? '').trim());
                        if (d == null || d <= 0) return l.roomInvalidRent;
                        return null;
                      },
                    ),
                    if (!_isEdit) ...[
                      const SizedBox(height: 16),
                      AppCard(
                        color: t.isDark ? t.surface : t.surface2,
                        child: Row(
                          children: [
                            IconPill(
                                icon: Icons.info_outline_rounded, color: t.sky),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                l.roomTenantInfo,
                                style: TextStyle(
                                    fontSize: 12,
                                    height: 1.5,
                                    color: t.text2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    AppButton.primary(
                      label: _isEdit ? l.commonSaveChanges : l.roomSave,
                      block: true,
                      loading: _saving,
                      onPressed: _save,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
