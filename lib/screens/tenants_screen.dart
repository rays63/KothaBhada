import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_theme.dart';
import '../providers/app_controller.dart';
import '../utils/date_formatter.dart';
import '../widgets/status_badge.dart';

class TenantsScreen extends StatelessWidget {
  const TenantsScreen({super.key, this.propertyId});

  final String? propertyId;

  @override
  Widget build(BuildContext context) {
    final snapshot = context.watch<AppController>().snapshot;
    if (snapshot == null) {
      return const Scaffold(body: SizedBox.shrink());
    }
    final tenants = propertyId == null
        ? snapshot.tenants
        : snapshot.tenants
              .where((item) => item.propertyId == propertyId)
              .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Tenants')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            Text(
              'Tenant Directory',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Centralized offline tenant contact and move-in information for operations.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.muted),
            ),
            const SizedBox(height: 18),
            ...tenants.map((tenant) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              tenant.name,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          StatusBadge(
                            label:
                                'Room ${tenant.roomId.split('-').last.toUpperCase()}',
                            background: AppTheme.surfaceLow,
                            foreground: AppTheme.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        tenant.phone.isEmpty ? 'Phone not set' : tenant.phone,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        tenant.emergencyContact.isEmpty
                            ? 'Emergency contact not set'
                            : tenant.emergencyContact,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Move-in: ${DateFormatter.date(tenant.moveInDate)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
