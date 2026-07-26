# Kothabhada — Product & Development Specification (v2)

**Status:** Ready for development
**Target:** Google Play Store, offline-first Android (Flutter also enables iOS later)

---

## 1. Product Summary

Kothabhada is a fully offline rental property management app for landlords who rent out individual rooms in one or more houses. It tracks tenants, rent, electricity, internet/utility costs, and payment status, entirely on-device with no backend, no login, and no internet dependency.

**Core decisions locked in for v1:**
| Decision | Choice |
|---|---|
| Monetization | Free, no ads |
| Backup/Restore | Manual file export/import (no cloud) |
| Language | Bilingual — English + Nepali |
| Room ↔ Tenant | One active tenant per room (no shared-room splitting) |
| App lock | PIN and biometric, both available as options |
| Electricity billing | Fixed rate per unit, entered manually per house |
| Rent reminders | Local notifications for due/overdue rent |
| Analytics | Full — trends, charts, per-house/room breakdown |

---

## 2. Tech Stack

- **Framework:** Flutter (latest stable)
- **Language:** Dart
- **Database:** SQLite via `sqflite`
- **State management:** Riverpod
- **File storage:** `path_provider`
- **Image capture:** `image_picker` (meter readings, documents)
- **Localization:** `flutter_localizations` + `.arb` files (en, ne)
- **Notifications:** `flutter_local_notifications`
- **App lock:** `local_auth` (biometric) + custom PIN screen (stored hashed via `flutter_secure_storage`)
- **Charts:** `fl_chart` or `syncfusion_flutter_charts`
- **File export/import:** `file_picker` + `share_plus`

No Firebase. No backend. No network permission required (except optionally none at all — worth removing INTERNET permission entirely for Play Store trust signals, since app is 100% offline).

---

## 3. Architecture

```
lib/
  core/            # constants, error handling, enums
  models/          # House, Room, Tenant, Electricity, Payment, Document
  database/        # sqflite schema, migrations, DAOs
  services/        # backup/export, notification, auth/lock, PDF/CSV export
  providers/       # Riverpod providers per feature
  screens/
    splash/
    home/
    house_detail/
    room_detail/
    tenant/
    electricity/
    payments/
    analytics/
    documents/
    settings/
    lock/
  widgets/         # shared cards, charts, status chips
  theme/           # colors, typography, spacing tokens
  l10n/            # en.arb, ne.arb
  utils/
```

---

## 4. Data Model

### House
| Field | Type | Notes |
|---|---|---|
| id | INTEGER PK | |
| name | TEXT | e.g. "Baneshwor House" |
| address | TEXT | optional |
| electricity_rate_per_unit | REAL | house-level fixed rate |
| created_at | DATETIME | |

### Room
| Field | Type | Notes |
|---|---|---|
| id | INTEGER PK | |
| house_id | FK → House | |
| room_number | TEXT | e.g. "2A" |
| monthly_rent | REAL | |
| status | ENUM | vacant / occupied |
| created_at | DATETIME | |

### Tenant
| Field | Type | Notes |
|---|---|---|
| id | INTEGER PK | |
| room_id | FK → Room | one active tenant per room |
| full_name | TEXT | |
| phone | TEXT | |
| move_in_date | DATE | |
| move_out_date | DATE | nullable — set on vacate |
| id_document_photo_path | TEXT | nullable |
| is_active | BOOLEAN | |

### ElectricityReading
| Field | Type | Notes |
|---|---|---|
| id | INTEGER PK | |
| room_id | FK → Room | |
| billing_month | TEXT | e.g. "2026-07" |
| previous_unit | REAL | |
| current_unit | REAL | |
| units_consumed | REAL | computed: current - previous |
| rate_used | REAL | copied from House at time of billing |
| amount | REAL | computed: units_consumed × rate_used |
| meter_photo_path | TEXT | nullable |

### UtilityCharge (Internet, water, garbage, etc.)
| Field | Type | Notes |
|---|---|---|
| id | INTEGER PK | |
| room_id | FK → Room | |
| type | ENUM | internet / water / garbage / other |
| billing_month | TEXT | |
| amount | REAL | |

### Payment
| Field | Type | Notes |
|---|---|---|
| id | INTEGER PK | |
| room_id | FK → Room | |
| tenant_id | FK → Tenant | |
| billing_month | TEXT | |
| rent_due | REAL | snapshot of room's monthly_rent |
| electricity_due | REAL | pulled from ElectricityReading |
| utility_due | REAL | sum of UtilityCharge for the month |
| total_due | REAL | computed |
| amount_paid | REAL | |
| status | ENUM | paid / due / partial |
| paid_date | DATE | nullable |

### Document
| Field | Type | Notes |
|---|---|---|
| id | INTEGER PK | |
| tenant_id | FK → Tenant | nullable |
| house_id | FK → House | nullable |
| title | TEXT | |
| file_path | TEXT | |
| type | ENUM | agreement / id_proof / other |
| created_at | DATETIME | |

---

## 5. Feature Specifications

### 5.1 Houses & Rooms
- Add/edit/delete House (name, address, electricity rate)
- Add/edit/delete Room under a House (room number, monthly rent)
- Room status auto-updates: occupied when an active tenant exists, vacant otherwise
- Deleting a House/Room with active tenants requires confirmation and cascades tenant move-out

### 5.2 Tenants
- Add tenant to a vacant room (move-in date, phone, optional ID photo)
- Move-out flow: sets `move_out_date`, `is_active = false`, room becomes vacant
- Tenant history retained per room (for records, not deleted)

### 5.3 Electricity
- Enter previous/current meter reading per room per month
- App computes units consumed and amount using the House's fixed rate
- Optional photo of meter as proof
- Rate changes on the House only apply to future billing months (historical readings keep their snapshot rate)

### 5.4 Utilities
- Add internet/water/garbage/other charges per room per month
- Flat amount entry, no unit-based calculation

### 5.5 Payments
- Auto-generates a monthly Payment record per occupied room combining rent + electricity + utilities
- Landlord marks payment as Paid (full), Partial (enter amount), or leaves as Due
- Status color coding: Green = Paid, Red = Due/Overdue, Yellow/Orange = Partial
- Overdue = Due status past the billing month's end date

### 5.6 Documents
- Attach files/photos to a Tenant or House (rental agreement, ID proof, etc.)
- Stored in app's local documents directory, referenced by path in DB

### 5.7 Analytics
- Monthly income trend (line/bar chart) across all houses
- Per-house and per-room income breakdown
- Paid vs Due vs Partial distribution (pie/donut chart)
- Electricity consumption trend per room
- Filterable by date range and by house

### 5.8 Backup & Restore
- Export: serializes full database to a single JSON file, saved via file picker or shared
- Import: reads a JSON file and restores/replaces local database, with a confirmation warning before overwrite
- No automatic or cloud backup in v1

### 5.9 App Lock
- On first launch: prompt to set up PIN (required) and optionally enable biometric
- On subsequent launches: lock screen requires PIN or biometric before showing any data
- Settings screen allows changing PIN or toggling biometric

### 5.10 Notifications
- Local notification generated when a Payment record's billing month reaches its due date without being marked Paid
- Additional reminder if still unpaid after the month ends (overdue)
- Notifications deep-link to the relevant Room/Payment screen

### 5.11 Localization
- Full UI in English and Nepali via `.arb` files
- Language toggle in Settings, applied instantly without app restart
- Currency displayed as NPR (रु) formatted per locale

---

## 6. Navigation

Bottom navigation, rounded floating style, 4 tabs:
1. **Dashboard** — house list, quick status, "Add House"
2. **Analytics** — charts and breakdowns
3. **Payments** — monthly payment list across all rooms, filterable
4. **Settings** — language, security, backup/restore, about

App lock screen sits above all navigation (shown before Dashboard on cold start).

---

## 7. Design System (carried over, confirmed)

- Primary gradient: deep teal → emerald green
- Background: light gray (#F6F7FB)
- Cards: white/light-tint, soft shadows, rounded corners
- Status colors: Green (Paid) / Red (Due) / Yellow-Orange (Partial)
- Typography: modern sans-serif, clear hierarchy (bold titles, semibold headings, soft secondary text)

---

## 8. Non-Functional Requirements

- App must launch and be usable with zero network permissions
- SQLite queries optimized with indexes on `room_id`, `house_id`, `billing_month`
- Smooth 60fps navigation transitions
- Data integrity: no orphaned Payment/ElectricityReading rows if a Room/House is deleted (cascade or soft-delete)

---

## 9. Play Store Readiness Checklist

- [ ] Privacy Policy page (required even for offline apps that use camera/storage — host as a simple static page or in-app screen)
- [ ] Data Safety form: declare that no data leaves the device, camera used only for local photo storage
- [ ] Target SDK: latest required Android API level at submission time
- [ ] App icon, feature graphic, screenshots (light + dark if supported)
- [ ] Signed release build (upload key via Play App Signing)
- [ ] Permissions requested: Camera, Photos/Storage (for `image_picker`), Notifications — each must be justified in Play Console
- [ ] Remove/avoid INTERNET permission if truly unused, to reinforce offline claim
- [ ] Test PIN/biometric lock recovery path (what happens if PIN is forgotten — needs a reset flow, e.g. reinstall warning, since there's no cloud account to recover via)

---

## 10. Open Items for Next Iteration

These aren't blocking a v1 build but should get a decision before or during development:

1. **PIN reset flow** — with no account/cloud, forgetting the PIN likely means data loss unless we add a "recovery via secret question" or explicit "reinstall wipes data" warning.
2. **Document types allowed** — restrict to PDF/image only, or any file type?
3. **Multiple electricity meters per room** — assume one meter per room; confirm this holds for all house configurations.
4. **Currency** — assumed NPR; confirm no multi-currency need.
5. **Rent change mid-tenancy** — if a landlord raises rent, does history stay accurate for past months? (Current schema snapshots rent at Payment-generation time, so this should already hold — worth a test case.)

---

## 11. Suggested Build Order (MVP path)

1. Database schema + models + DAOs
2. Houses & Rooms CRUD (Dashboard)
3. Tenants (add/move-out)
4. Electricity + Utilities entry
5. Payments generation + status marking
6. App lock (PIN + biometric)
7. Notifications
8. Analytics
9. Documents
10. Backup/Restore
11. Localization pass (en/ne)
12. Play Store packaging (icons, privacy policy, signing)
