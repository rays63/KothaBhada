import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n_ext.dart';
import '../../../data/models/models.dart';
import '../../../data/providers.dart';
import '../../../widgets/kit/kit.dart';
import '../widgets/screen_header.dart';

/// Add / Edit House (design screen 09).
class HouseFormScreen extends ConsumerStatefulWidget {
  const HouseFormScreen({super.key, this.house});

  final House? house;

  @override
  ConsumerState<HouseFormScreen> createState() => _HouseFormScreenState();
}

class _HouseFormScreenState extends ConsumerState<HouseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _address;
  late final TextEditingController _rate;
  bool _saving = false;

  bool get _isEdit => widget.house != null;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.house?.name ?? '');
    _address = TextEditingController(text: widget.house?.address ?? '');
    _rate = TextEditingController(
      text: widget.house == null
          ? ''
          : widget.house!.electricityRatePerUnit.toStringAsFixed(
              widget.house!.electricityRatePerUnit % 1 == 0 ? 0 : 2),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _address.dispose();
    _rate.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await ref.read(portfolioProvider.notifier).saveHouse(
          id: widget.house?.id,
          name: _name.text.trim(),
          address: _address.text.trim(),
          electricityRate: double.tryParse(_rate.text.trim()) ?? 0,
        );
    if (!mounted) return;
    Navigator.of(context).pop();
    showAppToast(
        context, _isEdit ? context.l10n.houseUpdated : context.l10n.houseAdded);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ScreenHeader(title: _isEdit ? l.houseEdit : l.houseAdd),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
                  children: [
                    AppTextField(
                      label: l.houseNameLabel,
                      hint: l.houseNameHint,
                      controller: _name,
                      textInputAction: TextInputAction.next,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? l.commonRequired
                          : null,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: l.houseAddressLabel,
                      hint: l.houseAddressHint,
                      controller: _address,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: l.houseRateLabel,
                      hint: l.houseRateHint,
                      controller: _rate,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'^\d*\.?\d*')),
                      ],
                      validator: (v) {
                        final d = double.tryParse((v ?? '').trim());
                        if (d == null || d <= 0) return l.houseInvalidRate;
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    AppButton.primary(
                      label: _isEdit ? l.commonSaveChanges : l.houseSave,
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
