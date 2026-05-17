import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/formatters/currency_formatter.dart';
import '../core/theme/app_theme.dart';
import '../models/property_models.dart';
import '../providers/app_controller.dart';
import '../utils/date_formatter.dart';

class ElectricityHistoryScreen extends StatefulWidget {
  const ElectricityHistoryScreen({
    super.key,
    required this.roomId,
    required this.roomLabel,
  });

  final String roomId;
  final String roomLabel;

  @override
  State<ElectricityHistoryScreen> createState() =>
      _ElectricityHistoryScreenState();
}

class _ElectricityHistoryScreenState extends State<ElectricityHistoryScreen> {
  bool _loading = true;
  String? _error;
  List<ElectricityReading> _readings = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final readings = await context
          .read<AppController>()
          .loadElectricityReadingsForRoom(widget.roomId);
      if (!mounted) return;
      setState(() {
        _readings = readings;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Unable to load history. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Room ${widget.roomLabel} History')),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _error!,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: _load,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            : _readings.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'No electricity readings yet for this room.',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: AppTheme.muted),
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                itemCount: _readings.length,
                itemBuilder: (context, index) {
                  final reading = _readings[index];
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
                          Text(
                            DateFormatter.dateTime(reading.recordedAt),
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(color: AppTheme.muted),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Prev ${reading.previousReading.toStringAsFixed(1)}  •  Current ${reading.currentReading.toStringAsFixed(1)}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Units ${reading.unitsConsumed.toStringAsFixed(1)} × Rate ${reading.rate.toStringAsFixed(2)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            CurrencyFormatter.nepali(reading.totalCost),
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(color: AppTheme.primary),
                          ),
                          if (reading.note.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Text(
                              reading.note,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
