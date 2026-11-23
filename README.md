# FishGuard Mobile App

Offline-first AI fish freshness & histamine hazard detector built with Flutter 3.50+, Riverpod 3.5+, and GoRouter.

---

## 🏛️ Scalable Architecture: Feature-First Clean MVVM + SOLID

FishGuard follows a feature-first Clean MVVM (Model - View - ViewModel) architecture with strict adherence to SOLID principles:

```
lib/
├── core/
│   ├── database/                  # Local offline persistence (Hive / Isar / SQLite)
│   ├── routing/                   # GoRouter declarative router, transitions, args
│   │   ├── app_router.dart        # Route declarations & navigation extensions
│   │   ├── app_routes.dart        # String constants & route names
│   │   └── route_arguments.dart   # Strongly-typed route argument DTOs
│   └── theme/                     # Design tokens (Colors, Typography, Spacing, Radius, Motion)
│
└── features/
    ├── home/                      # Example Riverpod MVVM implementation
    │   ├── models/                # Domain models (RecentScanModel)
    │   ├── repositories/          # Contract interfaces & implementations (RecentScansRepository)
    │   ├── viewmodels/            # Riverpod State & Notifiers (RecentScansState, RecentScansViewModel)
    │   ├── screens/               # ConsumerWidget / ConsumerStatefulWidget (HomeScreen)
    │   └── widgets/               # Focused, single-responsibility UI components
    │
    ├── scanner/                   # 2-Step Viewfinder Camera & 10s Sensory Check
    ├── verdict/                   # Safety Verdict, Freshness Gauge & Explainability
    ├── first_aid/                 # Offline Fish Poisoning Protocol & ER Guides
    └── onboarding/                # 3-Step Walkthrough & Custom Vector Illustrations
```

---

## 🌊 Riverpod MVVM Pattern & Conventions

### 1. Model (Entity)
Represents the immutable domain entity.
```dart
class RecentScanModel {
  final String species;
  final int freshnessScore;
  ...
}
```

### 2. Repository (Dependency Inversion Principle - DIP)
Always define an abstract interface before implementing data fetching or local storage.
```dart
abstract class RecentScansRepository {
  Future<List<RecentScanModel>> fetchRecentScans();
  Future<void> addScan(RecentScanModel scan);
}

final recentScansRepositoryProvider = Provider<RecentScansRepository>((ref) {
  return MockRecentScansRepository();
});
```

### 3. State
Immutable data container representing the UI state.
```dart
class RecentScansState {
  final RecentScansStatus status;
  final List<RecentScanModel> scans;
  final String? errorMessage;
  ...
}
```

### 4. ViewModel (Notifier)
Coordinates business logic, state mutations, and interaction with repositories.
```dart
class RecentScansViewModel extends Notifier<RecentScansState> {
  late final RecentScansRepository _repository;

  @override
  RecentScansState build() {
    _repository = ref.watch(recentScansRepositoryProvider);
    Future.microtask(() => loadScans());
    return const RecentScansState(status: RecentScansStatus.loading);
  }

  Future<void> loadScans() async {
    state = state.copyWith(status: RecentScansStatus.loading);
    try {
      final items = await _repository.fetchRecentScans();
      if (!ref.mounted) return;
      state = state.copyWith(status: RecentScansStatus.loaded, scans: items);
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(status: RecentScansStatus.error, errorMessage: e.toString());
    }
  }
}

final recentScansViewModelProvider =
    NotifierProvider<RecentScansViewModel, RecentScansState>(
  RecentScansViewModel.new,
);
```

### 5. View (ConsumerWidget)
Consumes state and triggers events without business logic.
```dart
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(recentScansViewModelProvider);

    return Scaffold(
      body: state.isLoading 
          ? const CircularProgressIndicator()
          : RecentScansCard(items: state.scans),
    );
  }
}
```

---

## 🧪 Testing & Dependency Overrides

Because Riverpod uses dependency injection, ViewModels and Screens can be tested in total isolation with zero mocks overhead:

```dart
test('override repository in test', () async {
  final fakeRepo = FakeScansRepository();
  final container = ProviderContainer(
    overrides: [
      recentScansRepositoryProvider.overrideWithValue(fakeRepo),
    ],
  );
  addTearDown(container.dispose);

  await container.read(recentScansViewModelProvider.notifier).loadScans();
  expect(container.read(recentScansViewModelProvider).scans.length, 0);
});
```
