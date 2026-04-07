import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kothabhada',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      builder: (context, child) =>
          KeyboardDoneOverlay(child: child ?? const SizedBox()),
      home: const RentalApp(),
    );
  }
}

ThemeData _buildTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  const primary = Color(0xFF006565);
  const primaryContainer = Color(0xFF008080);
  const secondary = Color(0xFF006E2F);
  const secondaryContainer = Color(0xFF6BFF8F);
  const error = Color(0xFFBA1A1A);
  const errorContainer = Color(0xFFFFDAD6);
  const surfaceLight = Color(0xFFF9F9FF);
  const surfaceDark = Color(0xFF141B2B);

  final scheme = ColorScheme.fromSeed(
    seedColor: primary,
    brightness: brightness,
    primary: primary,
    primaryContainer: primaryContainer,
    secondary: secondary,
    secondaryContainer: secondaryContainer,
    error: error,
    errorContainer: errorContainer,
    surface: isDark ? surfaceDark : surfaceLight,
  );

  final baseText = GoogleFonts.interTextTheme(
    ThemeData(brightness: brightness).textTheme,
  );
  final textTheme = baseText.copyWith(
    headlineLarge: GoogleFonts.manrope(
      textStyle: baseText.headlineLarge,
      fontWeight: FontWeight.w800,
      letterSpacing: -1.0,
    ),
    headlineMedium: GoogleFonts.manrope(
      textStyle: baseText.headlineMedium,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.8,
    ),
    headlineSmall: GoogleFonts.manrope(
      textStyle: baseText.headlineSmall,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
    ),
    titleLarge: GoogleFonts.manrope(
      textStyle: baseText.titleLarge,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.3,
    ),
    titleMedium: GoogleFonts.manrope(
      textStyle: baseText.titleMedium,
      fontWeight: FontWeight.w700,
    ),
    labelLarge: GoogleFonts.inter(
      textStyle: baseText.labelLarge,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.3,
    ),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    textTheme: textTheme.apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    ),
    cardTheme: CardThemeData(
      color: isDark ? const Color(0xFF1D2535) : const Color(0xFFF1F3FF),
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        shape: const StadiumBorder(),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        textStyle: GoogleFonts.manrope(
          fontWeight: FontWeight.w800,
          fontSize: 16,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        side: BorderSide(color: scheme.primary.withValues(alpha: 0.15)),
        foregroundColor: scheme.primary,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark ? const Color(0xFF293040) : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: const Color(0xFFBDC9C8).withValues(alpha: 0.18),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: const Color(0xFFBDC9C8).withValues(alpha: 0.18),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: scheme.primary.withValues(alpha: 0.35),
          width: 1.4,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      hintStyle: GoogleFonts.inter(
        color: scheme.onSurface.withValues(alpha: 0.4),
      ),
    ),
  );
}

class RentalApp extends StatefulWidget {
  const RentalApp({super.key});

  @override
  State<RentalApp> createState() => _RentalAppState();
}

class _RentalAppState extends State<RentalApp> {
  int selectedIndex = 0;
  late List<HouseData> houses = _sampleHouses;

  void addHouse(HouseData house) {
    setState(() {
      houses = [...houses, house];
      selectedIndex = 0;
    });
  }

  void updateHouse(HouseData updatedHouse) {
    setState(() {
      houses = houses
          .map((house) => house.id == updatedHouse.id ? updatedHouse : house)
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardScreen(houses: houses, onUpdateHouse: updateHouse),
      AddHouseScreen(
        onSaved: addHouse,
        onBack: () => setState(() => selectedIndex = 0),
      ),
      HistoryScreen(historyItems: _sampleHistory),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.09),
                    Theme.of(context).colorScheme.surface,
                    Theme.of(context).colorScheme.surface,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: IndexedStack(index: selectedIndex, children: pages),
          ),
          if (selectedIndex == 0)
            Positioned(
              right: 22,
              bottom: 92,
              child: FloatingActionButton(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                onPressed: () => setState(() => selectedIndex = 1),
                child: const Icon(Icons.add_rounded, size: 30),
              ),
            ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: selectedIndex,
        onTap: (index) => setState(() => selectedIndex = index),
      ),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.houses,
    required this.onUpdateHouse,
  });

  final List<HouseData> houses;
  final ValueChanged<HouseData> onUpdateHouse;

  @override
  Widget build(BuildContext context) {
    final totalIncome = houses.fold<double>(
      0,
      (sum, house) => sum + house.monthlyTarget,
    );
    final pendingPayments = houses.fold<double>(
      0,
      (sum, house) => sum + house.totalDue,
    );
    final occupied = houses.fold<int>(
      0,
      (sum, house) => sum + house.occupiedRooms,
    );
    final totalRooms = houses.fold<int>(
      0,
      (sum, house) => sum + house.rooms.length,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
      children: [
        const TopHeader(
          leading: Icons.menu_rounded,
          title: 'Kothabhada',
          trailingAvatar: true,
        ),
        const SizedBox(height: 24),
        Text(
          'OVERVIEW',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 11,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Portfolio Health',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontSize: 38),
        ),
        const SizedBox(height: 14),
        const DatePill(label: 'October 2023'),
        const SizedBox(height: 18),
        DashboardMetricCard(
          title: 'TOTAL INCOME',
          value: _formatCurrency(totalIncome),
          subtitle: '12% from last month',
          accent: Theme.of(context).colorScheme.primary,
          icon: Icons.account_balance_wallet_rounded,
        ),
        const SizedBox(height: 16),
        DashboardMetricCard(
          title: 'PENDING PAYMENTS',
          value: _formatCurrency(pendingPayments),
          subtitle: '8 invoices overdue',
          accent: Theme.of(context).colorScheme.error,
          icon: Icons.error_outline_rounded,
        ),
        const SizedBox(height: 16),
        OccupancyCard(occupied: occupied, total: totalRooms),
        const SizedBox(height: 28),
        Row(
          children: [
            Expanded(
              child: Text(
                'Your Houses',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            TextButton(onPressed: () {}, child: const Text('View Map Mode')),
          ],
        ),
        const SizedBox(height: 10),
        ...houses.map(
          (house) => Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: HouseShowcaseCard(
              house: house,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => HouseDetailScreen(
                      initialHouse: house,
                      onChanged: onUpdateHouse,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class AddHouseScreen extends StatefulWidget {
  const AddHouseScreen({
    super.key,
    required this.onSaved,
    required this.onBack,
  });

  final ValueChanged<HouseData> onSaved;
  final VoidCallback onBack;

  @override
  State<AddHouseScreen> createState() => _AddHouseScreenState();
}

class _AddHouseScreenState extends State<AddHouseScreen> {
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final roomsController = TextEditingController();
  final notesController = TextEditingController();
  bool isActive = true;

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    roomsController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
      children: [
        TopHeader(
          leading: Icons.arrow_back_ios_new_rounded,
          title: 'Kothabhada',
          trailingAvatar: true,
          onLeadingTap: widget.onBack,
        ),
        const SizedBox(height: 26),
        Text(
          'PROPERTY MANAGEMENT',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontSize: 11,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Add New House',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Define the architectural identity and operational capacity of your new rental asset.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.62),
            fontStyle: FontStyle.italic,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ImageUploadPlaceholder(),
              const SizedBox(height: 22),
              AppTextField(
                controller: nameController,
                label: 'House Name',
                hintText: 'e.g., Willow Creek Estate',
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: addressController,
                label: 'Full Address',
                hintText: 'Enter the complete legal address...',
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: roomsController,
                label: 'Total Rooms',
                hintText: '0',
                keyboardType: TextInputType.number,
                prefixIcon: Icons.meeting_room_rounded,
              ),
              const SizedBox(height: 16),
              Text('Status', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: SegmentedPill(
                      label: 'ACTIVE',
                      selected: isActive,
                      onTap: () => setState(() => isActive = true),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SegmentedPill(
                      label: 'DRAFT',
                      selected: !isActive,
                      onTap: () => setState(() => isActive = false),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: notesController,
                label: 'Internal Notes',
                hintText:
                    'Mention specific amenities, maintenance schedules, or historical details...',
                maxLines: 4,
              ),
              const SizedBox(height: 26),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    final roomCount =
                        int.tryParse(roomsController.text.trim()) ?? 0;
                    widget.onSaved(
                      HouseData(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: nameController.text.trim().isEmpty
                            ? 'New House'
                            : nameController.text.trim(),
                        address: addressController.text.trim().isEmpty
                            ? 'Address not added'
                            : addressController.text.trim(),
                        category: isActive ? 'ACTIVE' : 'DRAFT',
                        imageUrl:
                            'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&w=1200&q=80',
                        monthlyTarget: roomCount * 15000,
                        rooms: List.generate(
                          roomCount,
                          (index) => RoomData(
                            id: 'new-$index',
                            name: 'Room ${index + 1}',
                            tenantName: 'Vacant',
                            phone: 'No tenant assigned',
                            rent: 0,
                            isRentPaid: false,
                            lastReading: 0,
                            currentReading: 0,
                            ratePerUnit: 12,
                            electricityHistory: const [],
                            fixedInternetCost: 0,
                            isInternetPaid: false,
                            water: 0,
                            garbage: 0,
                            other: 0,
                            partialPayment: 0,
                          ),
                        ),
                      ),
                    );
                  },
                  child: const Text('Save House'),
                ),
              ),
              const SizedBox(height: 18),
              Center(
                child: TextButton(
                  onPressed: widget.onBack,
                  child: const Text('Cancel and return'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({
    super.key,
    required this.historyItems,
    this.title = 'History',
    this.brand = 'Kothabhada',
    this.onBack,
  });

  final List<HistoryItem> historyItems;
  final String title;
  final String brand;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
      children: [
        TopHeader(
          leading: Icons.arrow_back_ios_new_rounded,
          title: title,
          brand: brand,
          onLeadingTap: onBack,
        ),
        const SizedBox(height: 22),
        InfoSummaryCard(
          title: 'Total Paid (2023)',
          value: 'Rs1,45,000',
          subtitle: 'Across 10 billing cycles',
          trailingIcon: Icons.account_balance_wallet_rounded,
        ),
        const SizedBox(height: 14),
        DarkHighlightCard(
          title: 'Average Electricity',
          value: '142 Units',
          subtitle: 'Per month average consumption',
          icon: Icons.bolt_rounded,
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: Text(
                'Billing Timeline',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            TextButton(onPressed: () {}, child: const Text('Filter by Year')),
          ],
        ),
        const SizedBox(height: 8),
        ...historyItems.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: BillingTimelineCard(item: item),
          ),
        ),
        const SizedBox(height: 18),
        Column(
          children: [
            Icon(
              Icons.topic_outlined,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.28),
            ),
            const SizedBox(height: 8),
            Text(
              'End of 2023 Records',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.35),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool paymentReminders = true;
  bool messages = true;
  bool billAlerts = false;
  bool lightTheme = true;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
      children: [
        const TopHeader(
          leading: Icons.arrow_back_ios_new_rounded,
          title: 'Settings',
          brand: 'Kothabhada',
        ),
        const SizedBox(height: 22),
        SettingsSection(
          title: 'Preferences',
          child: Column(
            children: [
              const SettingsRow(
                icon: Icons.account_balance_wallet_rounded,
                title: 'Currency',
                trailingText: 'USD',
              ),
              const Divider(height: 1, color: Colors.transparent),
              const SettingsRow(
                icon: Icons.language_rounded,
                title: 'Language',
                trailingText: 'English',
              ),
              const Divider(height: 1, color: Colors.transparent),
              SettingsThemeRow(
                lightTheme: lightTheme,
                onLight: () => setState(() => lightTheme = true),
                onDark: () => setState(() => lightTheme = false),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        SettingsSection(
          title: 'Notifications',
          child: Column(
            children: [
              ToggleSettingsRow(
                title: 'Payment Reminders',
                subtitle: 'Get notified before rent is due',
                value: paymentReminders,
                onChanged: (value) => setState(() => paymentReminders = value),
              ),
              const SizedBox(height: 16),
              ToggleSettingsRow(
                title: 'New Message Alerts',
                subtitle: 'Alerts for tenant inquiries',
                value: messages,
                onChanged: (value) => setState(() => messages = value),
              ),
              const SizedBox(height: 16),
              ToggleSettingsRow(
                title: 'Bill Generation Alerts',
                subtitle: 'Monthly utility bill updates',
                value: billAlerts,
                onChanged: (value) => setState(() => billAlerts = value),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        SettingsSection(
          title: 'Account & Security',
          child: Column(
            children: const [
              SettingsRow(
                icon: Icons.person_rounded,
                title: 'Profile Settings',
              ),
              SizedBox(height: 16),
              SettingsRow(icon: Icons.lock_rounded, title: 'Change Password'),
              SizedBox(height: 16),
              SettingsRow(
                icon: Icons.verified_user_rounded,
                title: 'Two-Factor Authentication',
                trailingPill: 'Enabled',
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        SettingsSection(
          title: 'Support & About',
          child: Column(
            children: const [
              SettingsRow(
                icon: Icons.help_rounded,
                title: 'Help Center',
                external: true,
              ),
              SizedBox(height: 16),
              SettingsRow(
                icon: Icons.description_rounded,
                title: 'Terms of Service',
              ),
              SizedBox(height: 16),
              SettingsRow(
                icon: Icons.privacy_tip_rounded,
                title: 'Privacy Policy',
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Text(
            'APP VERSION V1.2.0',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontSize: 11,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.38),
              letterSpacing: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 28),
        OutlinedButton.icon(
          onPressed: () {},
          icon: Icon(
            Icons.logout_rounded,
            color: Theme.of(context).colorScheme.error,
          ),
          label: Text(
            'Logout from Account',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: Theme.of(
                context,
              ).colorScheme.error.withValues(alpha: 0.18),
            ),
            padding: const EdgeInsets.symmetric(vertical: 18),
          ),
        ),
      ],
    );
  }
}

class HouseDetailScreen extends StatefulWidget {
  const HouseDetailScreen({
    super.key,
    required this.initialHouse,
    required this.onChanged,
  });

  final HouseData initialHouse;
  final ValueChanged<HouseData> onChanged;

  @override
  State<HouseDetailScreen> createState() => _HouseDetailScreenState();
}

class _HouseDetailScreenState extends State<HouseDetailScreen> {
  late HouseData house = widget.initialHouse;

  void save(HouseData updated) {
    setState(() => house = updated);
    widget.onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
          children: [
            TopHeader(
              leading: Icons.arrow_back_ios_new_rounded,
              title: house.name,
              brand: 'Kothabhada',
              onLeadingTap: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () async {
                  final edited = await Navigator.of(context).push<HouseData>(
                    MaterialPageRoute(
                      builder: (_) => EditHouseScreen(initialHouse: house),
                    ),
                  );
                  if (edited != null) {
                    save(edited);
                  }
                },
                icon: const Icon(Icons.edit_rounded, size: 18),
                label: const Text('Edit House'),
              ),
            ),
            const SizedBox(height: 18),
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: AspectRatio(
                aspectRatio: 1.45,
                child: PropertyArtCard(house: house, compact: false),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    house.address,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.62),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: MiniStat(
                          label: 'Rooms',
                          value: '${house.rooms.length}',
                        ),
                      ),
                      Expanded(
                        child: MiniStat(
                          label: 'Income',
                          value: _formatCurrency(house.monthlyTarget),
                        ),
                      ),
                      Expanded(
                        child: MiniStat(
                          label: 'Due',
                          value: _formatCurrency(house.totalDue),
                          accent: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Rooms',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ...house.rooms.map(
              (room) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: RoomListCard(
                  room: room,
                  onTap: () async {
                    final updatedRoom = await Navigator.of(context)
                        .push<RoomData>(
                          MaterialPageRoute(
                            builder: (_) => RoomDetailScreen(initialRoom: room),
                          ),
                        );
                    if (updatedRoom != null) {
                      final updatedRooms = house.rooms
                          .map(
                            (item) =>
                                item.id == updatedRoom.id ? updatedRoom : item,
                          )
                          .toList();
                      save(house.copyWith(rooms: updatedRooms));
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RoomDetailScreen extends StatefulWidget {
  const RoomDetailScreen({super.key, required this.initialRoom});

  final RoomData initialRoom;

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  late RoomData room = widget.initialRoom;
  late final TextEditingController readingController;
  String? readingError;

  List<HistoryItem> get roomHistoryItems => _historyFromRoom(room);

  @override
  void initState() {
    super.initState();
    readingController = TextEditingController(
      text: room.currentReading.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    readingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final previewReading = _parseDouble(
      readingController.text,
      fallback: room.currentReading,
    );
    final effectiveReading = math.max(room.lastReading, previewReading);
    final units = math.max(0, effectiveReading - room.lastReading);
    final electricityCost = units * room.ratePerUnit;
    final utilitiesTotal = room.water + room.garbage + room.other;
    final total =
        room.rent + electricityCost + room.fixedInternetCost + utilitiesTotal;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
          children: [
            TopHeader(
              leading: Icons.arrow_back_ios_new_rounded,
              title: room.tenantName,
              brand: 'Kothabhada',
              onLeadingTap: () => Navigator.of(context).pop(room),
            ),
            const SizedBox(height: 18),
            HighlightTenantCard(
              room: room,
              onViewHistory: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => HistoryRouteScreen(
                      title: '${room.name} History',
                      historyItems: roomHistoryItems,
                    ),
                  ),
                );
              },
              onChangeSettings: () async {
                final updatedRoom = await Navigator.of(context).push<RoomData>(
                  MaterialPageRoute(
                    builder: (_) => RoomSettingsScreen(initialRoom: room),
                  ),
                );
                if (updatedRoom != null) {
                  setState(() {
                    room = updatedRoom;
                    readingController.text = updatedRoom.currentReading
                        .toStringAsFixed(0);
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            DetailInfoCard(
              title: 'Monthly Rent',
              icon: Icons.home_rounded,
              trailing: StatusChip(
                label: room.isRentPaid ? 'PAID' : 'UNPAID',
                positive: room.isRentPaid,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatCurrency(room.rent),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => setState(
                      () => room = room.copyWith(isRentPaid: !room.isRentPaid),
                    ),
                    child: Text(
                      room.isRentPaid ? 'Marked Paid' : 'Mark as Paid',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            DetailInfoCard(
              title: 'Electricity',
              icon: Icons.bolt_rounded,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: InfoCell(
                          label: 'PREV READING',
                          value: room.lastReading.toStringAsFixed(1),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AppTextField(
                          controller: readingController,
                          label: 'Current Reading',
                          keyboardType: TextInputType.number,
                          helperText:
                              readingError ??
                              'Must be at least ${room.lastReading.toStringAsFixed(0)}',
                          onChanged: (value) {
                            final parsed = double.tryParse(value);
                            if (parsed == null) {
                              setState(() => readingError = null);
                              return;
                            }
                            if (parsed < room.lastReading) {
                              setState(() {
                                readingError =
                                    'Current reading cannot be less than previous reading';
                              });
                            } else {
                              setState(() => readingError = null);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: InfoCell(
                          label: 'UNITS',
                          value: units.toStringAsFixed(0),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: InfoCell(
                          label: 'COST',
                          value: _formatCurrency(electricityCost),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  InfoCell(
                    label: 'RATE / UNIT',
                    value: 'Rs${room.ratePerUnit.toStringAsFixed(2)}',
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      FilledButton.tonal(
                        onPressed: () {
                          final parsedReading = _parseDouble(
                            readingController.text,
                            fallback: room.currentReading,
                          );
                          if (parsedReading < room.lastReading) {
                            setState(() {
                              readingError =
                                  'Current reading cannot be less than previous reading';
                              readingController.text = room.lastReading
                                  .toStringAsFixed(0);
                            });
                            return;
                          }
                          if (parsedReading == room.lastReading) {
                            setState(() {
                              readingError =
                                  'Enter a reading greater than the previous reading';
                            });
                            return;
                          }
                          setState(() {
                            readingError = null;
                            final historyEntry = ElectricityHistoryEntry(
                              label: _currentBillingLabel(),
                              previousReading: room.lastReading,
                              currentReading: parsedReading,
                              rate: room.ratePerUnit,
                            );
                            room = room.copyWith(
                              lastReading: parsedReading,
                              currentReading: parsedReading,
                              electricityHistory: [
                                historyEntry,
                                ...room.electricityHistory,
                              ],
                            );
                            readingController.text = parsedReading
                                .toStringAsFixed(0);
                          });
                        },
                        child: const Text('Save Reading'),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => HistoryRouteScreen(
                                title: '${room.name} History',
                                historyItems: roomHistoryItems,
                              ),
                            ),
                          );
                        },
                        child: const Text('View History'),
                      ),
                    ],
                  ),
                  if (room.electricityHistory.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Recent History',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    ...room.electricityHistory
                        .take(3)
                        .map(
                          (entry) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: InfoCell(
                              label: entry.label ?? 'Saved Reading',
                              value:
                                  '${entry.previousReading.toStringAsFixed(0)} → ${entry.currentReading.toStringAsFixed(0)}  •  Rs${((entry.currentReading - entry.previousReading) * entry.rate).toStringAsFixed(0)}',
                            ),
                          ),
                        ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            DetailInfoCard(
              title: 'Total Summary',
              icon: Icons.receipt_long_rounded,
              emphasized: true,
              child: Column(
                children: [
                  SummaryLine(
                    label: 'Rent',
                    value: _formatCurrency(room.rent),
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  const SizedBox(height: 10),
                  SummaryLine(
                    label: 'Electricity',
                    value: _formatCurrency(electricityCost),
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  const SizedBox(height: 10),
                  SummaryLine(
                    label: 'Internet',
                    value: _formatCurrency(room.fixedInternetCost),
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  const SizedBox(height: 10),
                  SummaryLine(
                    label: 'Utilities',
                    value: _formatCurrency(utilitiesTotal),
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  const SizedBox(height: 14),
                  SummaryLine(
                    label: 'Grand Total',
                    value: _formatCurrency(total),
                    strong: true,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RoomSettingsScreen extends StatefulWidget {
  const RoomSettingsScreen({super.key, required this.initialRoom});

  final RoomData initialRoom;

  @override
  State<RoomSettingsScreen> createState() => _RoomSettingsScreenState();
}

class _RoomSettingsScreenState extends State<RoomSettingsScreen> {
  late final TextEditingController tenantController;
  late final TextEditingController phoneController;
  late final TextEditingController rentController;
  late final TextEditingController internetController;
  late final TextEditingController rateController;
  late final TextEditingController waterController;
  late final TextEditingController garbageController;
  late final TextEditingController otherController;

  @override
  void initState() {
    super.initState();
    final room = widget.initialRoom;
    tenantController = TextEditingController(text: room.tenantName);
    phoneController = TextEditingController(text: room.phone);
    rentController = TextEditingController(text: room.rent.toStringAsFixed(0));
    internetController = TextEditingController(
      text: room.fixedInternetCost.toStringAsFixed(0),
    );
    rateController = TextEditingController(
      text: room.ratePerUnit.toStringAsFixed(2),
    );
    waterController = TextEditingController(
      text: room.water.toStringAsFixed(0),
    );
    garbageController = TextEditingController(
      text: room.garbage.toStringAsFixed(0),
    );
    otherController = TextEditingController(
      text: room.other.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    tenantController.dispose();
    phoneController.dispose();
    rentController.dispose();
    internetController.dispose();
    rateController.dispose();
    waterController.dispose();
    garbageController.dispose();
    otherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
          children: [
            TopHeader(
              leading: Icons.arrow_back_ios_new_rounded,
              title: 'Room Settings',
              brand: 'Kothabhada',
              onLeadingTap: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    controller: tenantController,
                    label: 'Tenant Name',
                    hintText: 'Enter tenant name',
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: phoneController,
                    label: 'Phone Number',
                    hintText: '+977 980-1234567',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: rentController,
                    label: 'Monthly Rent',
                    hintText: '0',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: internetController,
                    label: 'Internet Cost',
                    hintText: '0',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: rateController,
                    label: 'Electricity Unit Price',
                    hintText: '0.00',
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    helperText:
                        'Cost charged for each consumed electricity unit',
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AppTextField(
                          controller: waterController,
                          label: 'Water',
                          hintText: '0',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AppTextField(
                          controller: garbageController,
                          label: 'Garbage',
                          hintText: '0',
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: otherController,
                    label: 'Other',
                    hintText: '0',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(context).pop(
                          widget.initialRoom.copyWith(
                            tenantName: tenantController.text.trim().isEmpty
                                ? widget.initialRoom.tenantName
                                : tenantController.text.trim(),
                            phone: phoneController.text.trim().isEmpty
                                ? widget.initialRoom.phone
                                : phoneController.text.trim(),
                            rent: _parseDouble(
                              rentController.text,
                              fallback: widget.initialRoom.rent,
                            ),
                            fixedInternetCost: _parseDouble(
                              internetController.text,
                              fallback: widget.initialRoom.fixedInternetCost,
                            ),
                            ratePerUnit: _parseDouble(
                              rateController.text,
                              fallback: widget.initialRoom.ratePerUnit,
                            ),
                            water: _parseDouble(
                              waterController.text,
                              fallback: widget.initialRoom.water,
                            ),
                            garbage: _parseDouble(
                              garbageController.text,
                              fallback: widget.initialRoom.garbage,
                            ),
                            other: _parseDouble(
                              otherController.text,
                              fallback: widget.initialRoom.other,
                            ),
                          ),
                        );
                      },
                      child: const Text('Save Changes'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HistoryRouteScreen extends StatelessWidget {
  const HistoryRouteScreen({
    super.key,
    required this.title,
    required this.historyItems,
  });

  final String title;
  final List<HistoryItem> historyItems;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: HistoryScreen(
          title: title,
          brand: 'Kothabhada',
          historyItems: historyItems,
          onBack: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }
}

class EditHouseScreen extends StatefulWidget {
  const EditHouseScreen({super.key, required this.initialHouse});

  final HouseData initialHouse;

  @override
  State<EditHouseScreen> createState() => _EditHouseScreenState();
}

class _EditHouseScreenState extends State<EditHouseScreen> {
  late final TextEditingController nameController;
  late final TextEditingController addressController;
  late final TextEditingController roomCountController;
  bool isPremium = true;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.initialHouse.name);
    addressController = TextEditingController(
      text: widget.initialHouse.address,
    );
    roomCountController = TextEditingController(
      text: widget.initialHouse.rooms.length.toString(),
    );
    isPremium = widget.initialHouse.category == 'PREMIUM';
  }

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    roomCountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 24),
          children: [
            TopHeader(
              leading: Icons.arrow_back_ios_new_rounded,
              title: 'Edit House',
              brand: 'Kothabhada',
              onLeadingTap: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppTextField(
                    controller: nameController,
                    label: 'House Name',
                    hintText: 'Enter house name',
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: addressController,
                    label: 'Full Address',
                    hintText: 'Enter house address',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: roomCountController,
                    label: 'Total Rooms',
                    hintText: '0',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Category',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: SegmentedPill(
                          label: 'PREMIUM',
                          selected: isPremium,
                          onTap: () => setState(() => isPremium = true),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SegmentedPill(
                          label: 'RESIDENTIAL',
                          selected: !isPremium,
                          onTap: () => setState(() => isPremium = false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        final newCount =
                            int.tryParse(roomCountController.text.trim()) ??
                            widget.initialHouse.rooms.length;
                        final currentRooms = [...widget.initialHouse.rooms];
                        final adjustedRooms = currentRooms.length > newCount
                            ? currentRooms.take(newCount).toList()
                            : [
                                ...currentRooms,
                                ...List.generate(
                                  newCount - currentRooms.length,
                                  (index) => RoomData(
                                    id: 'added-${DateTime.now().microsecondsSinceEpoch}-$index',
                                    name:
                                        'Room ${currentRooms.length + index + 1}',
                                    tenantName: 'Vacant',
                                    phone: 'No tenant assigned',
                                    rent: 0,
                                    isRentPaid: false,
                                    lastReading: 0,
                                    currentReading: 0,
                                    ratePerUnit: 12.5,
                                    electricityHistory: const [],
                                    fixedInternetCost: 0,
                                    isInternetPaid: false,
                                    water: 0,
                                    garbage: 0,
                                    other: 0,
                                    partialPayment: 0,
                                  ),
                                ),
                              ];
                        Navigator.of(context).pop(
                          widget.initialHouse.copyWith(
                            name: nameController.text.trim().isEmpty
                                ? widget.initialHouse.name
                                : nameController.text.trim(),
                            address: addressController.text.trim().isEmpty
                                ? widget.initialHouse.address
                                : addressController.text.trim(),
                            category: isPremium ? 'PREMIUM' : 'RESIDENTIAL',
                            rooms: adjustedRooms,
                            monthlyTarget: math.max(1, newCount) * 6200,
                          ),
                        );
                      },
                      child: const Text('Save House Changes'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final items = const [
      (Icons.home_filled, 'HOME'),
      (Icons.domain_rounded, 'HOUSES'),
      (Icons.history_rounded, 'HISTORY'),
      (Icons.settings_rounded, 'SETTINGS'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1B2330)
            : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF141B2B).withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 18),
      child: Row(
        children: List.generate(items.length, (index) {
          final selected = currentIndex == index;
          final item = items[index];
          return Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(999),
              onTap: () => onTap(index),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Icon(
                        item.$1,
                        size: 20,
                        color: selected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.34),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.$2,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontSize: 9,
                        letterSpacing: 0.8,
                        color: selected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.34),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class TopHeader extends StatelessWidget {
  const TopHeader({
    super.key,
    required this.leading,
    required this.title,
    this.brand,
    this.trailingAvatar = false,
    this.onLeadingTap,
  });

  final IconData leading;
  final String title;
  final String? brand;
  final bool trailingAvatar;
  final VoidCallback? onLeadingTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: onLeadingTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(
              leading,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        if (brand != null)
          Text(
            brand!,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        if (trailingAvatar)
          Container(
            height: 32,
            width: 32,
            margin: const EdgeInsets.only(left: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.2),
              ),
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.12),
            ),
            child: Icon(
              Icons.person_rounded,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
      ],
    );
  }
}

class DatePill extends StatelessWidget {
  const DatePill({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_month_rounded,
            size: 16,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }
}

class DashboardMetricCard extends StatelessWidget {
  const DashboardMetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.accent,
    required this.icon,
  });

  final String title;
  final String value;
  final String subtitle;
  final Color accent;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border(left: BorderSide(color: accent, width: 3)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF141B2B).withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent, size: 18),
          const SizedBox(height: 12),
          Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontSize: 10,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: accent, fontSize: 24),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: accent,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class OccupancyCard extends StatelessWidget {
  const OccupancyCard({super.key, required this.occupied, required this.total});

  final int occupied;
  final int total;

  @override
  Widget build(BuildContext context) {
    final rate = total == 0 ? 0.0 : occupied / total;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border(
          left: BorderSide(
            color: Theme.of(context).colorScheme.secondary,
            width: 3,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF141B2B).withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.meeting_room_rounded,
            size: 18,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(height: 12),
          Text(
            'OCCUPIED ROOMS',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontSize: 10,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$occupied / $total',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontSize: 24),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: rate,
              minHeight: 4,
              backgroundColor: const Color(0xFFDCE2F7),
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(rate * 100).toStringAsFixed(1)}% occupancy rate',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}

class HouseShowcaseCard extends StatelessWidget {
  const HouseShowcaseCard({
    super.key,
    required this.house,
    required this.onTap,
  });

  final HouseData house;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final paid = house.totalDue == 0;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1.55,
                    child: PropertyArtCard(house: house),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      house.category,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontSize: 9,
                        color: Theme.of(context).colorScheme.primary,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              house.name,
                              style: Theme.of(
                                context,
                              ).textTheme.titleLarge?.copyWith(fontSize: 24),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              house.address,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatShortCurrency(house.monthlyTarget),
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary,
                                  fontSize: 22,
                                ),
                          ),
                          Text(
                            'MONTHLY\nTARGET',
                            textAlign: TextAlign.right,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  fontSize: 8,
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.45),
                                  letterSpacing: 0.8,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Icon(
                        Icons.meeting_room_rounded,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text('${house.rooms.length} Rooms'),
                      const SizedBox(width: 18),
                      Icon(
                        paid
                            ? Icons.check_circle_rounded
                            : Icons.payments_rounded,
                        size: 16,
                        color: paid
                            ? Theme.of(context).colorScheme.secondary
                            : Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        paid
                            ? 'All Paid'
                            : '${_formatCurrency(house.totalDue)} Due',
                        style: TextStyle(
                          color: paid
                              ? Theme.of(context).colorScheme.secondary
                              : Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ImageUploadPlaceholder extends StatelessWidget {
  const ImageUploadPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE3E8FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_a_photo_rounded,
            size: 34,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.25),
          ),
          const SizedBox(height: 12),
          Text(
            'UPLOAD EXTERIOR COVER PHOTO',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontSize: 10,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.4),
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class SegmentedPill extends StatelessWidget {
  const SegmentedPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).colorScheme.primary
              : const Color(0xFFDCE2F7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: selected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.55),
            fontSize: 11,
            letterSpacing: 1.1,
          ),
        ),
      ),
    );
  }
}

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hintText,
    this.keyboardType,
    this.maxLines = 1,
    this.prefixIcon,
    this.helperText,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String? hintText;
  final TextInputType? keyboardType;
  final int maxLines;
  final IconData? prefixIcon;
  final String? helperText;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 8),
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontSize: 16),
          ),
        ),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          textInputAction: maxLines > 1
              ? TextInputAction.newline
              : TextInputAction.done,
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          onSubmitted: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText,
            helperText: helperText,
            prefixIcon: prefixIcon == null
                ? null
                : Icon(
                    prefixIcon,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
          ),
        ),
      ],
    );
  }
}

class InfoSummaryCard extends StatelessWidget {
  const InfoSummaryCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.trailingIcon,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData trailingIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
              Icon(
                trailingIcon,
                color: Theme.of(context).colorScheme.primary,
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.58),
            ),
          ),
        ],
      ),
    );
  }
}

class DarkHighlightCard extends StatelessWidget {
  const DarkHighlightCard({
    super.key,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onPrimary.withValues(alpha: 0.82),
                  ),
                ),
              ),
              Icon(
                icon,
                color: Theme.of(context).colorScheme.onPrimary,
                size: 18,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onPrimary.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class BillingTimelineCard extends StatelessWidget {
  const BillingTimelineCard({super.key, required this.item});

  final HistoryItem item;

  @override
  Widget build(BuildContext context) {
    final positive = item.status == HistoryStatus.paid;
    final neutral = item.status == HistoryStatus.partial;
    final accent = positive
        ? Theme.of(context).colorScheme.secondary
        : neutral
        ? const Color(0xFFE5A400)
        : Theme.of(context).colorScheme.error;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border(
          left: BorderSide(
            color: accent,
            width: item.status == HistoryStatus.unpaid ? 3 : 0,
          ),
        ),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                item.month,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontSize: 22),
              ),
              const SizedBox(width: 8),
              StatusChip(
                label: item.statusLabel,
                positive: positive,
                neutral: neutral,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            item.reference,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.58),
            ),
          ),
          if (item.status == HistoryStatus.unpaid) ...[
            const SizedBox(height: 6),
            Text(
              'Payment Overdue by 12 Days',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TimelineStat(
                  label: 'CONSUMPTION',
                  value: '${item.units} Units',
                ),
              ),
              Expanded(
                child: TimelineStat(
                  label: 'TOTAL AMOUNT',
                  value: _formatCurrency(item.total),
                  accent: accent,
                ),
              ),
            ],
          ),
          if (item.showDetails) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: InfoCell(
                    label: 'PREV READING',
                    value: item.previousReading,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InfoCell(
                    label: 'CURR READING',
                    value: item.currentReading,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: InfoCell(label: 'RATE / UNIT', value: item.rate),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    height: 78,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F3FF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.receipt_long_rounded, size: 16),
                        label: const Text('Invoice'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (item.status == HistoryStatus.unpaid) ...[
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: () {},
                child: const Text('Pay Now'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class SettingsSection extends StatelessWidget {
  const SettingsSection({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.all(18),
          child: child,
        ),
      ],
    );
  }
}

class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.icon,
    required this.title,
    this.trailingText,
    this.trailingPill,
    this.external = false,
  });

  final IconData icon;
  final String title;
  final String? trailingText;
  final String? trailingPill;
  final bool external;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontSize: 16),
          ),
        ),
        if (trailingText != null)
          Text(
            trailingText!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        if (trailingPill != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              trailingPill!,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontSize: 10,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
        const SizedBox(width: 8),
        Icon(
          external ? Icons.open_in_new_rounded : Icons.chevron_right_rounded,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
        ),
      ],
    );
  }
}

class SettingsThemeRow extends StatelessWidget {
  const SettingsThemeRow({
    super.key,
    required this.lightTheme,
    required this.onLight,
    required this.onDark,
  });

  final bool lightTheme;
  final VoidCallback onLight;
  final VoidCallback onDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.dark_mode_rounded,
          color: Theme.of(context).colorScheme.primary,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Theme',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontSize: 16),
          ),
        ),
        ThemeToggleChip(label: 'Light', selected: lightTheme, onTap: onLight),
        const SizedBox(width: 8),
        ThemeToggleChip(label: 'Dark', selected: !lightTheme, onTap: onDark),
      ],
    );
  }
}

class ThemeToggleChip extends StatelessWidget {
  const ThemeToggleChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? Theme.of(context).colorScheme.primary
              : const Color(0xFFDCE2F7),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontSize: 11,
            color: selected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.55),
          ),
        ),
      ),
    );
  }
}

class ToggleSettingsRow extends StatelessWidget {
  const ToggleSettingsRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.58),
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: Colors.white,
          activeTrackColor: Theme.of(context).colorScheme.primary,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: const Color(0xFFDCE2F7),
        ),
      ],
    );
  }
}

class HighlightTenantCard extends StatelessWidget {
  const HighlightTenantCard({
    super.key,
    required this.room,
    required this.onViewHistory,
    required this.onChangeSettings,
  });

  final RoomData room;
  final VoidCallback onViewHistory;
  final VoidCallback onChangeSettings;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.person_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 14),
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
                      room.phone,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.call_rounded),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                OutlinedButton.icon(
                  onPressed: onViewHistory,
                  icon: const Icon(Icons.description_outlined, size: 18),
                  label: const Text('View History'),
                ),
                OutlinedButton.icon(
                  onPressed: onChangeSettings,
                  icon: const Icon(Icons.tune_rounded, size: 18),
                  label: const Text('Change Room Settings'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DetailInfoCard extends StatelessWidget {
  const DetailInfoCard({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
    this.emphasized = false,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final foreground = emphasized
        ? scheme.onPrimaryContainer
        : scheme.onSurface;

    return Container(
      decoration: BoxDecoration(
        color: emphasized
            ? scheme.primaryContainer
            : Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(18),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: foreground),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: <Widget?>[
                Container(
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    color: emphasized
                        ? Colors.white.withValues(alpha: 0.14)
                        : scheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: emphasized ? foreground : scheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: foreground),
                  ),
                ),
                trailing,
              ].nonNulls.toList(),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    this.positive = false,
    this.neutral = false,
  });

  final String label;
  final bool positive;
  final bool neutral;

  @override
  Widget build(BuildContext context) {
    final color = positive
        ? Theme.of(context).colorScheme.secondary
        : neutral
        ? const Color(0xFFE5A400)
        : Theme.of(context).colorScheme.error;
    final background = positive
        ? Theme.of(context).colorScheme.secondaryContainer
        : neutral
        ? const Color(0xFFFFF4CC)
        : Theme.of(context).colorScheme.errorContainer;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(fontSize: 9, color: color),
      ),
    );
  }
}

class SummaryLine extends StatelessWidget {
  const SummaryLine({
    super.key,
    required this.label,
    required this.value,
    this.strong = false,
    this.color,
  });

  final String label;
  final String value;
  final bool strong;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: TextStyle(color: color)),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: strong ? FontWeight.w800 : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

class TimelineStat extends StatelessWidget {
  const TimelineStat({
    super.key,
    required this.label,
    required this.value,
    this.accent,
  });

  final String label;
  final String value;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontSize: 10,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.45),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: accent),
        ),
      ],
    );
  }
}

class InfoCell extends StatelessWidget {
  const InfoCell({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontSize: 9,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.45),
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class MiniStat extends StatelessWidget {
  const MiniStat({
    super.key,
    required this.label,
    required this.value,
    this.accent,
  });

  final String label;
  final String value;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            fontSize: 10,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.46),
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: accent),
        ),
      ],
    );
  }
}

class RoomListCard extends StatelessWidget {
  const RoomListCard({super.key, required this.room, required this.onTap});

  final RoomData room;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    room.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    room.tenantName,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            StatusChip(
              label: room.totalDue == 0 ? 'PAID' : 'DUE',
              positive: room.totalDue == 0,
            ),
          ],
        ),
      ),
    );
  }
}

class PropertyArtCard extends StatelessWidget {
  const PropertyArtCard({super.key, required this.house, this.compact = true});

  final HouseData house;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final palette = house.category == 'PREMIUM'
        ? const [Color(0xFFB5D7FF), Color(0xFFF4E7C8), Color(0xFF7FA86D)]
        : const [Color(0xFFC6E4FF), Color(0xFFF7D8D4), Color(0xFFA6C8E0)];
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [palette[0], palette[1]],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: compact ? 34 : 56,
            child: Container(color: palette[2]),
          ),
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.all(compact ? 18 : 26),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.topRight,
                      child: Icon(
                        Icons.wb_sunny_rounded,
                        color: Colors.white.withValues(alpha: 0.75),
                        size: compact ? 18 : 24,
                      ),
                    ),
                  ),
                  Container(
                    width: compact ? 112 : 160,
                    height: compact ? 70 : 96,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.88),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF141B2B).withValues(alpha: 0.1),
                          blurRadius: 18,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          left: 8,
                          right: 8,
                          top: 12,
                          child: Container(
                            height: compact ? 18 : 22,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE4CFA8),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                        Positioned(
                          left: compact ? 12 : 16,
                          right: compact ? 12 : 16,
                          bottom: 12,
                          child: Row(
                            children: List.generate(
                              4,
                              (_) => Expanded(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 2,
                                  ),
                                  height: compact ? 22 : 28,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFAEC7E8),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          left: compact ? 46 : 66,
                          child: Container(
                            width: compact ? 18 : 24,
                            height: compact ? 32 : 42,
                            decoration: BoxDecoration(
                              color: const Color(0xFF8D6E63),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class KeyboardDoneOverlay extends StatelessWidget {
  const KeyboardDoneOverlay({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Stack(
      children: [
        Positioned.fill(child: child),
        if (bottomInset > 0)
          Positioned(
            right: 16,
            bottom: bottomInset + 12,
            child: SafeArea(
              child: FilledButton(
                onPressed: () => FocusManager.instance.primaryFocus?.unfocus(),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
                child: const Text('Done'),
              ),
            ),
          ),
      ],
    );
  }
}

class HouseData {
  const HouseData({
    required this.id,
    required this.name,
    required this.address,
    required this.category,
    required this.imageUrl,
    required this.monthlyTarget,
    required this.rooms,
  });

  final String id;
  final String name;
  final String address;
  final String category;
  final String imageUrl;
  final double monthlyTarget;
  final List<RoomData> rooms;

  int get occupiedRooms =>
      rooms.where((room) => room.tenantName != 'Vacant').length;

  double get totalDue =>
      rooms.fold<double>(0, (sum, room) => sum + room.totalDue);

  HouseData copyWith({
    String? id,
    String? name,
    String? address,
    String? category,
    String? imageUrl,
    double? monthlyTarget,
    List<RoomData>? rooms,
  }) {
    return HouseData(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      monthlyTarget: monthlyTarget ?? this.monthlyTarget,
      rooms: rooms ?? this.rooms,
    );
  }
}

class RoomData {
  const RoomData({
    required this.id,
    required this.name,
    required this.tenantName,
    required this.phone,
    required this.rent,
    required this.isRentPaid,
    required this.lastReading,
    required this.currentReading,
    required this.ratePerUnit,
    required this.electricityHistory,
    required this.fixedInternetCost,
    required this.isInternetPaid,
    required this.water,
    required this.garbage,
    required this.other,
    required this.partialPayment,
  });

  final String id;
  final String name;
  final String tenantName;
  final String phone;
  final double rent;
  final bool isRentPaid;
  final double lastReading;
  final double currentReading;
  final double ratePerUnit;
  final List<ElectricityHistoryEntry> electricityHistory;
  final double fixedInternetCost;
  final bool isInternetPaid;
  final double water;
  final double garbage;
  final double other;
  final double partialPayment;

  double get totalDue {
    final basePaid =
        (isRentPaid ? rent : 0) + (isInternetPaid ? fixedInternetCost : 0);
    final electricityCost =
        math.max(0, currentReading - lastReading) * ratePerUnit;
    final total =
        rent + fixedInternetCost + electricityCost + water + garbage + other;
    return math.max(0, total - basePaid - partialPayment);
  }

  RoomData copyWith({
    String? id,
    String? name,
    String? tenantName,
    String? phone,
    double? rent,
    bool? isRentPaid,
    double? lastReading,
    double? currentReading,
    double? ratePerUnit,
    List<ElectricityHistoryEntry>? electricityHistory,
    double? fixedInternetCost,
    bool? isInternetPaid,
    double? water,
    double? garbage,
    double? other,
    double? partialPayment,
  }) {
    return RoomData(
      id: id ?? this.id,
      name: name ?? this.name,
      tenantName: tenantName ?? this.tenantName,
      phone: phone ?? this.phone,
      rent: rent ?? this.rent,
      isRentPaid: isRentPaid ?? this.isRentPaid,
      lastReading: lastReading ?? this.lastReading,
      currentReading: currentReading ?? this.currentReading,
      ratePerUnit: ratePerUnit ?? this.ratePerUnit,
      electricityHistory: electricityHistory ?? this.electricityHistory,
      fixedInternetCost: fixedInternetCost ?? this.fixedInternetCost,
      isInternetPaid: isInternetPaid ?? this.isInternetPaid,
      water: water ?? this.water,
      garbage: garbage ?? this.garbage,
      other: other ?? this.other,
      partialPayment: partialPayment ?? this.partialPayment,
    );
  }
}

class ElectricityHistoryEntry {
  const ElectricityHistoryEntry({
    this.label,
    required this.previousReading,
    required this.currentReading,
    required this.rate,
  });

  final String? label;
  final double previousReading;
  final double currentReading;
  final double rate;
}

enum HistoryStatus { paid, partial, unpaid }

class HistoryItem {
  const HistoryItem({
    required this.month,
    required this.reference,
    required this.units,
    required this.total,
    required this.status,
    this.previousReading = '',
    this.currentReading = '',
    this.rate = '',
    this.showDetails = false,
  });

  final String month;
  final String reference;
  final int units;
  final double total;
  final HistoryStatus status;
  final String previousReading;
  final String currentReading;
  final String rate;
  final bool showDetails;

  String get statusLabel {
    switch (status) {
      case HistoryStatus.paid:
        return 'PAID';
      case HistoryStatus.partial:
        return 'PARTIAL';
      case HistoryStatus.unpaid:
        return 'UNPAID';
    }
  }
}

String _formatCurrency(double value) => 'Rs${value.toStringAsFixed(0)}';

double _parseDouble(String value, {required double fallback}) {
  return double.tryParse(value.trim()) ?? fallback;
}

String _currentBillingLabel() {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  final now = DateTime.now();
  return '${months[now.month - 1]} ${now.year}';
}

String _formatShortCurrency(double value) {
  if (value >= 1000) {
    return '\$${(value / 1000).toStringAsFixed(1)}k';
  }
  return '\$${value.toStringAsFixed(0)}';
}

List<HistoryItem> _historyFromRoom(RoomData room) {
  if (room.electricityHistory.isEmpty) {
    return _sampleHistory;
  }

  return room.electricityHistory.asMap().entries.map((entry) {
    final index = entry.key;
    final item = entry.value;
    final units = math
        .max(0, item.currentReading - item.previousReading)
        .round();
    final total =
        (units * item.rate) +
        room.rent +
        room.fixedInternetCost +
        room.water +
        room.garbage +
        room.other;
    return HistoryItem(
      month: item.label ?? 'Cycle ${index + 1}',
      reference: 'Room ${room.name} • Billing entry',
      units: units,
      total: total,
      status: index == 0 ? HistoryStatus.paid : HistoryStatus.partial,
      previousReading: item.previousReading.toStringAsFixed(1),
      currentReading: item.currentReading.toStringAsFixed(1),
      rate: 'Rs${item.rate.toStringAsFixed(2)}',
      showDetails: true,
    );
  }).toList();
}

const List<HistoryItem> _sampleHistory = [
  HistoryItem(
    month: 'October 2023',
    reference: 'Transaction ID: #KTH-88291',
    units: 156,
    total: 14250,
    status: HistoryStatus.paid,
    previousReading: '2450.0',
    currentReading: '2606.0',
    rate: 'Rs12.50',
    showDetails: true,
  ),
  HistoryItem(
    month: 'September 2023',
    reference: 'Transaction ID: #KTH-77312',
    units: 132,
    total: 12800,
    status: HistoryStatus.paid,
  ),
  HistoryItem(
    month: 'August 2023',
    reference: 'Transaction ID: #KTH-66203',
    units: 168,
    total: 15120,
    status: HistoryStatus.unpaid,
  ),
];

const List<HouseData> _sampleHouses = [
  HouseData(
    id: 'h1',
    name: 'The Emerald Estate',
    address: '122nd Street, Beverly Hills, CA',
    category: 'PREMIUM',
    imageUrl:
        'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&w=1200&q=80',
    monthlyTarget: 12400,
    rooms: [
      RoomData(
        id: 'r1',
        name: 'Room A-01',
        tenantName: 'Arjun Shrestha',
        phone: '+977 980-1234567',
        rent: 18000,
        isRentPaid: true,
        lastReading: 2450,
        currentReading: 2606,
        ratePerUnit: 12.5,
        electricityHistory: [],
        fixedInternetCost: 1200,
        isInternetPaid: true,
        water: 400,
        garbage: 150,
        other: 0,
        partialPayment: 0,
      ),
      RoomData(
        id: 'r2',
        name: 'Room A-02',
        tenantName: 'Mina Karki',
        phone: '+977 986-0099887',
        rent: 16500,
        isRentPaid: false,
        lastReading: 1880,
        currentReading: 2012,
        ratePerUnit: 12.5,
        electricityHistory: [],
        fixedInternetCost: 1000,
        isInternetPaid: false,
        water: 350,
        garbage: 150,
        other: 0,
        partialPayment: 4000,
      ),
    ],
  ),
  HouseData(
    id: 'h2',
    name: 'Pine Ridge Heights',
    address: 'Alpine Way, Denver, CO',
    category: 'RESIDENTIAL',
    imageUrl:
        'https://images.unsplash.com/photo-1448630360428-65456885c650?auto=format&fit=crop&w=1200&q=80',
    monthlyTarget: 8100,
    rooms: [
      RoomData(
        id: 'r3',
        name: 'Studio B-04',
        tenantName: 'Rupesh Rai',
        phone: '+977 980-8877665',
        rent: 15000,
        isRentPaid: true,
        lastReading: 1200,
        currentReading: 1325,
        ratePerUnit: 12.5,
        electricityHistory: [],
        fixedInternetCost: 1100,
        isInternetPaid: true,
        water: 300,
        garbage: 120,
        other: 0,
        partialPayment: 0,
      ),
      RoomData(
        id: 'r4',
        name: 'Studio B-05',
        tenantName: 'Vacant',
        phone: 'No tenant assigned',
        rent: 0,
        isRentPaid: false,
        lastReading: 0,
        currentReading: 0,
        ratePerUnit: 12.5,
        electricityHistory: [],
        fixedInternetCost: 0,
        isInternetPaid: false,
        water: 0,
        garbage: 0,
        other: 0,
        partialPayment: 0,
      ),
    ],
  ),
];
