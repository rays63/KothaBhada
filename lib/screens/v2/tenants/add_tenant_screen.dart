import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n_ext.dart';
import '../../../data/providers.dart';
import '../../../widgets/kit/kit.dart';
import '../widgets/screen_header.dart';

/// Add Tenant to a vacant room (design screen 15). A minimal version wired for
/// the room-detail flow; the full tenant profile lands in Phase 6.
class AddTenantScreen extends ConsumerStatefulWidget {
  const AddTenantScreen({super.key, required this.roomId});

  final String roomId;

  @override
  ConsumerState<AddTenantScreen> createState() => _AddTenantScreenState();
}

class _AddTenantScreenState extends ConsumerState<AddTenantScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _citizenship = TextEditingController();
  final _emergency = TextEditingController();
  DateTime _moveIn = DateTime.now();
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _citizenship.dispose();
    _emergency.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    await ref.read(portfolioProvider.notifier).addTenant(
          roomId: widget.roomId,
          fullName: _name.text.trim(),
          phone: _phone.text.trim(),
          moveInDate: _moveIn,
          citizenshipNo: _citizenship.text.trim(),
          emergencyContact: _emergency.text.trim(),
        );
    if (!mounted) return;
    Navigator.of(context).pop();
    showAppToast(context, context.l10n.tenantAdded);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ScreenHeader(title: l.tenantAdd),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(22, 8, 22, 24),
                  children: [
                    AppTextField(
                      label: l.tenantFullName,
                      hint: l.tenantFullNameHint,
                      controller: _name,
                      textInputAction: TextInputAction.next,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? l.commonRequired
                          : null,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: l.tenantPhone,
                      hint: l.tenantPhoneHint,
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 14),
                    AppDateField(
                      label: l.tenantMoveInDate,
                      value: _moveIn,
                      lastDate: DateTime.now(),
                      onChanged: (d) => setState(() => _moveIn = d),
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: l.tenantCitizenship,
                      hint: l.tenantCitizenshipHint,
                      controller: _citizenship,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: l.tenantEmergency,
                      hint: l.tenantEmergencyHint,
                      controller: _emergency,
                    ),
                    const SizedBox(height: 22),
                    AppButton.primary(
                      label: l.tenantSave,
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
