import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/formatters/currency_formatter.dart';
import '../core/theme/app_theme.dart';
import '../models/payment_status.dart';
import '../models/property_models.dart';
import '../providers/app_controller.dart';
import '../widgets/status_badge.dart';
import 'documents_screen.dart';
import 'history_screen.dart';
import 'property_form_screen.dart';
import 'room_form_screen.dart';
import 'tenants_screen.dart';
import 'utilities_screen.dart';

class PropertyDetailScreen extends StatelessWidget {
  const PropertyDetailScreen({super.key, required this.propertyId});

  final String propertyId;

  @override
  Widget build(BuildContext context) {
    final snapshot = context.watch<AppController>().snapshot;
    if (snapshot == null) return const Scaffold(body: SizedBox.shrink());
    final property = snapshot.properties.firstWhere(
      (item) => item.id == propertyId,
      orElse: () => snapshot.properties.first,
    );

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: AppTheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Kothabhada',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: AppTheme.primary),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => _editProperty(context, property),
                  icon: const Icon(
                    Icons.edit_outlined,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              property.name,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_outlined, color: AppTheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    property.address,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppTheme.ink),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _addRoom(context, property),
                    icon: const Icon(Icons.add_business_rounded),
                    label: const Text('Add Room'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                color: const Color(0xFFE7ECFF),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _StatBlock(
                      label: 'CAPACITY',
                      value: '${property.totalRooms}',
                      subtitle: 'Total Rooms',
                    ),
                  ),
                  const Icon(
                    Icons.meeting_room_outlined,
                    color: AppTheme.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primary, AppTheme.primaryContainer],
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: _StatBlock(
                label: 'MONTHLY TARGET',
                value: CurrencyFormatter.nepali(property.monthlyTarget),
                subtitle: 'Expected Revenue',
                light: true,
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(26),
              decoration: BoxDecoration(
                color: const Color(0xFFE3E8FF),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _StatBlock(
                      label: 'OUTSTANDING',
                      value: CurrencyFormatter.nepali(property.totalDue),
                      subtitle: 'Total Dues',
                      valueColor: AppTheme.due,
                      labelColor: AppTheme.due,
                    ),
                  ),
                  const Icon(Icons.warning_amber_rounded, color: AppTheme.due),
                ],
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              height: 54,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _ShortcutPill(
                    label: 'Tenants',
                    icon: Icons.people_alt_outlined,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => TenantsScreen(propertyId: property.id),
                      ),
                    ),
                  ),
                  _ShortcutPill(
                    label: 'Utilities',
                    icon: Icons.bolt_outlined,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            UtilitiesScreen(propertyId: property.id),
                      ),
                    ),
                  ),
                  _ShortcutPill(
                    label: 'Documents',
                    icon: Icons.description_outlined,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            DocumentsScreen(propertyId: property.id),
                      ),
                    ),
                  ),
                  _ShortcutPill(
                    label: 'History',
                    icon: Icons.history_rounded,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => HistoryScreen(propertyId: property.id),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Active Rooms',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                StatusBadge(
                  label:
                      '${property.rooms.where((room) => room.status == PaymentStatus.paid).length} Paid',
                  background: const Color(0xFF7EF38B),
                  foreground: const Color(0xFF106530),
                ),
                const SizedBox(width: 8),
                StatusBadge(
                  label:
                      '${property.rooms.where((room) => room.status != PaymentStatus.paid).length} Due',
                  background: const Color(0xFFFFD3D3),
                  foreground: AppTheme.due,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...property.rooms.map(
              (room) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: InkWell(
                  borderRadius: BorderRadius.circular(26),
                  onTap: () => _editRoom(context, property, room),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF141B2B,
                          ).withValues(alpha: 0.04),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDDE4FB),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Center(
                            child: Text(
                              room.label,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(color: AppTheme.primary),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                room.tenantName,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Rent due: ${room.dueDay}th of month',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                room.note,
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        StatusBadge(
                          label: room.status == PaymentStatus.paid
                              ? 'Paid'
                              : room.status == PaymentStatus.partial
                              ? 'Partial'
                              : 'Due',
                          background: room.status == PaymentStatus.paid
                              ? const Color(0xFF7EF38B)
                              : room.status == PaymentStatus.partial
                              ? const Color(0xFFFFE0A8)
                              : const Color(0xFFFFD3D3),
                          foreground: room.status == PaymentStatus.paid
                              ? const Color(0xFF106530)
                              : room.status == PaymentStatus.partial
                              ? const Color(0xFF915F00)
                              : AppTheme.due,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addRoom(context, property),
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 34),
      ),
    );
  }

  Future<void> _editProperty(
    BuildContext context,
    RentalProperty property,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PropertyFormScreen(property: property)),
    );
  }

  Future<void> _addRoom(BuildContext context, RentalProperty property) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => RoomFormScreen(property: property)),
    );
  }

  Future<void> _editRoom(
    BuildContext context,
    RentalProperty property,
    Room room,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RoomFormScreen(property: property, room: room),
      ),
    );
  }
}

class _StatBlock extends StatelessWidget {
  const _StatBlock({
    required this.label,
    required this.value,
    required this.subtitle,
    this.light = false,
    this.valueColor,
    this.labelColor,
  });

  final String label;
  final String value;
  final String subtitle;
  final bool light;
  final Color? valueColor;
  final Color? labelColor;

  @override
  Widget build(BuildContext context) {
    final foreground = light ? Colors.white : AppTheme.ink;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: labelColor ?? foreground.withValues(alpha: 0.85),
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(color: valueColor ?? foreground),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: foreground.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }
}

class _ShortcutPill extends StatelessWidget {
  const _ShortcutPill({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.surfaceLow,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: AppTheme.primary),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: AppTheme.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
