import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/format.dart';
import '../../../core/l10n_ext.dart';
import '../../../data/models/models.dart';
import '../../../data/providers.dart';
import '../../../widgets/kit/kit.dart';
import '../documents/document_tile.dart';
import '../widgets/screen_header.dart';

/// Tenant profile (design screen 16): details, quick call/message, documents
/// and move-out.
class TenantProfileScreen extends ConsumerWidget {
  const TenantProfileScreen({super.key, required this.tenantId});

  final String tenantId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final l = context.l10n;
    final snap = ref.watch(snapshotProvider);
    final tenant = snap?.tenantById(tenantId);
    if (snap == null || tenant == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final room = snap.roomOf(tenant.roomId);
    final house = room == null ? null : snap.houseOf(room.houseId);
    final docs = (ref.watch(documentsProvider).valueOrNull ?? const [])
        .where((d) => d.tenantId == tenantId)
        .toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ScreenHeader(
              title: '',
              trailing: HeaderIconButton(
                icon: Icons.edit_outlined,
                color: t.brand2,
                onTap: () => _edit(context, ref, tenant),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(22, 0, 22, 28),
                children: [
                  Column(
                    children: [
                      InitialsAvatar(
                          label: tenant.fullName, size: 80, radius: 26),
                      const SizedBox(height: 10),
                      Text(tenant.fullName,
                          style: Theme.of(context).textTheme.headlineMedium),
                      const SizedBox(height: 8),
                      if (room != null)
                        StatusChip(
                          label: l.tenantRoomHouse(
                              room.roomNumber, house?.name ?? ''),
                          kind: StatusKind.paid,
                        ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton.outline(
                          label: l.tenantCall,
                          icon: Icons.call_outlined,
                          onPressed: tenant.phone.isEmpty
                              ? null
                              : () => _launch('tel:${tenant.phone}', context),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AppButton.outline(
                          label: l.tenantMessage,
                          icon: Icons.sms_outlined,
                          onPressed: tenant.phone.isEmpty
                              ? null
                              : () => _launch('sms:${tenant.phone}', context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _InfoCard(rows: [
                    (l.tenantInfoPhone, tenant.phone.isEmpty ? '—' : tenant.phone),
                    (l.tenantInfoMoveIn, dayLabel(tenant.moveInDate)),
                    if (tenant.citizenshipNo.isNotEmpty)
                      (l.tenantInfoCitizenship, tenant.citizenshipNo),
                    if (tenant.emergencyContact.isNotEmpty)
                      (l.tenantInfoEmergency, tenant.emergencyContact),
                    if (room != null)
                      (l.tenantInfoRent, money(room.monthlyRent)),
                  ]),
                  const SizedBox(height: 18),
                  SectionHeader(title: l.tenantDocuments),
                  const SizedBox(height: 10),
                  if (docs.isEmpty)
                    Text(l.tenantNoDocuments,
                        style: TextStyle(fontSize: 13, color: t.text2))
                  else
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final d in docs)
                          SizedBox(
                            width:
                                (MediaQuery.of(context).size.width - 44 - 10) / 2,
                            child: DocumentTile(document: d),
                          ),
                      ],
                    ),
                  const SizedBox(height: 20),
                  AppButton.danger(
                    label: l.tenantMoveOutAction,
                    icon: Icons.logout_rounded,
                    block: true,
                    onPressed: () => _moveOut(context, ref, tenant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launch(String uri, BuildContext context) async {
    final ok = await launchUrl(Uri.parse(uri));
    if (!ok && context.mounted) {
      showAppToast(context, context.l10n.tenantCouldNotOpen, success: false);
    }
  }

  Future<void> _moveOut(
      BuildContext context, WidgetRef ref, Tenant tenant) async {
    final ok = await showConfirmDialog(
      context,
      title: context.l10n.tenantMoveOutTitle(tenant.fullName),
      message: context.l10n.tenantMoveOutBody,
      confirmLabel: context.l10n.tenantMoveOut,
      danger: true,
    );
    if (ok) {
      await ref.read(portfolioProvider.notifier).moveOutTenant(tenant.id);
      if (context.mounted) {
        Navigator.of(context).pop();
        showAppToast(context, context.l10n.tenantMovedOut);
      }
    }
  }

  Future<void> _edit(BuildContext context, WidgetRef ref, Tenant tenant) async {
    final name = TextEditingController(text: tenant.fullName);
    final phone = TextEditingController(text: tenant.phone);
    final citizenship = TextEditingController(text: tenant.citizenshipNo);
    final emergency = TextEditingController(text: tenant.emergencyContact);
    final saved = await showAppSheet<bool>(
      context,
      builder: (ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(ctx.l10n.tenantEdit,
              style: Theme.of(ctx).textTheme.headlineSmall),
          const SizedBox(height: 14),
          AppTextField(label: ctx.l10n.tenantFullName, controller: name),
          const SizedBox(height: 12),
          AppTextField(
              label: ctx.l10n.tenantPhone,
              controller: phone,
              keyboardType: TextInputType.phone),
          const SizedBox(height: 12),
          AppTextField(
              label: ctx.l10n.tenantInfoCitizenship, controller: citizenship),
          const SizedBox(height: 12),
          AppTextField(
              label: ctx.l10n.tenantInfoEmergency, controller: emergency),
          const SizedBox(height: 18),
          AppButton.primary(
            label: ctx.l10n.commonSave,
            block: true,
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );
    if (saved == true && name.text.trim().isNotEmpty) {
      await ref.read(portfolioProvider.notifier).updateTenant(
            tenantId: tenant.id,
            fullName: name.text.trim(),
            phone: phone.text.trim(),
            citizenshipNo: citizenship.text.trim(),
            emergencyContact: emergency.text.trim(),
          );
    }
    name.dispose();
    phone.dispose();
    citizenship.dispose();
    emergency.dispose();
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.rows});
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(AppTokens.rCard),
        boxShadow: t.shadowSm,
        border: t.isDark ? Border.all(color: t.line) : null,
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(rows[i].$1,
                      style: TextStyle(fontSize: 13, color: t.text2)),
                  Flexible(
                    child: Text(rows[i].$2,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            if (i != rows.length - 1) Divider(height: 1, color: t.line),
          ],
        ],
      ),
    );
  }
}
