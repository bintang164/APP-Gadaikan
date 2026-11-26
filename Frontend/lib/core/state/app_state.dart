import 'package:flutter/material.dart';
import '../models/gadaikan_models.dart';
import '../services/gadaikan_repository.dart';

/// Central application state coordinator backed by [GadaikanRepository].
class AppState extends ChangeNotifier {
  AppState(this._repository);

  final GadaikanRepository _repository;

  UserProfile? _user;
  SimulationConfig? _simulationConfig;
  List<PawnCategoryInfo> _categories = const [];
  List<PawnApplication> _applications = const [];
  PagedApplications? _applicationPage;
  bool _isLoadingApplications = false;
  String? _applicationListError;
  String _applicationFilter = 'all';
  List<PawnTransaction> _transactions = const [];
  List<OutletInfo> _outlets = const [];
  List<PromoInfo> _promotions = const [];
  List<AppNotification> _notifications = const [];
  List<FaqItem> _faqs = const [];

  bool _isLoadingData = false;
  String? _dataError;
  bool _hasSeenOnboarding = false;

  UserProfile? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get hasSeenOnboarding => _hasSeenOnboarding;
  SimulationConfig? get simulationConfig => _simulationConfig;
  List<PawnCategoryInfo> get categories => _categories;
  List<PawnApplication> get applications => _applications;
  PagedApplications? get applicationPage => _applicationPage;
  bool get isLoadingApplications => _isLoadingApplications;
  String? get applicationListError => _applicationListError;
  String get applicationFilter => _applicationFilter;
  List<PawnTransaction> get transactions => _transactions;
  List<OutletInfo> get outlets => _outlets;
  List<PromoInfo> get promotions => _promotions;
  List<AppNotification> get notifications => _notifications;
  List<FaqItem> get faqs => _faqs;
  bool get isLoadingData => _isLoadingData;
  String? get dataError => _dataError;
  bool get usesBackend => _repository.usesBackend;

  int get unreadNotificationCount =>
      _notifications.where((n) => !n.isRead).length;

  int get pendingApplicationCount =>
      _applications.where((a) => a.status.isPendingAction).length;

  /// Memuat daftar pengajuan dengan filter & pagination.
  Future<void> loadApplicationsPage({
    String? status,
    int page = 1,
    bool append = false,
  }) async {
    final String resolvedStatus = status ?? _applicationFilter;
    _applicationFilter = resolvedStatus;
    _isLoadingApplications = true;
    _applicationListError = null;
    notifyListeners();
    try {
      final PagedApplications result = await _repository.getApplicationsPage(
        status: resolvedStatus == 'all' ? null : resolvedStatus,
        page: page,
      );
      final List<PawnApplication> merged = append && page > 1
          ? <PawnApplication>[..._applicationPage?.items ?? <PawnApplication>[], ...result.items]
          : result.items;
      _applicationPage = PagedApplications(
        items: merged,
        page: result.page,
        perPage: result.perPage,
        total: result.total,
        isDemo: result.isDemo,
      );
      if (!append || page <= 1) _applications = merged;
    } catch (error) {
      _applicationListError =
          error.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoadingApplications = false;
      notifyListeners();
    }
  }

  /// Memuat ulang satu pengajuan dari server agar timeline/status segar.
  Future<PawnApplication> loadApplicationDetail(String id) async {
    final PawnApplication detail = await _repository.getApplicationDetail(id);
    final int index = _applications.indexWhere((PawnApplication app) => app.id == id);
    if (index == -1) {
      _applications = <PawnApplication>[detail, ..._applications];
    } else {
      final List<PawnApplication> updated = List<PawnApplication>.from(_applications);
      updated[index] = detail;
      _applications = updated;
    }
    notifyListeners();
    return detail;
  }

  Future<void> setApplicationFilter(String status) async {
    await loadApplicationsPage(status: status, page: 1);
  }

  Future<void> loadMoreApplications() async {
    final PagedApplications? current = _applicationPage;
    if (current == null || !current.hasMore || _isLoadingApplications) return;
    await loadApplicationsPage(page: current.page + 1, append: true);
  }

  void completeOnboarding() {
    _hasSeenOnboarding = true;
    notifyListeners();
  }

  Future<bool> initialize() async {
    _user = await _repository.restoreSession();
    _simulationConfig = await _repository.getSimulationConfig();
    _categories = await _repository.getCategories();
    if (_user != null) {
      await refreshAllData();
    }
    notifyListeners();
    return _user != null;
  }

  Future<void> login({
    required String identifier,
    required String password,
  }) async {
    _user = await _repository.login(
      identifier: identifier,
      password: password,
    );
    await refreshAllData();
    notifyListeners();
  }

  Future<void> register({
    required String name,
    required String phone,
    String? email,
    required String password,
  }) async {
    _user = await _repository.register(
      name: name,
      phone: phone,
      email: email,
      password: password,
    );
    await refreshAllData();
    notifyListeners();
  }

  Future<void> logout() async {
    await _repository.logout();
    _user = null;
    notifyListeners();
  }

  Future<void> updateProfile(UserProfile updated) async {
    _user = await _repository.updateProfile(updated);
    notifyListeners();
  }

  Future<void> refreshAllData() async {
    _isLoadingData = true;
    _dataError = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _repository.getSimulationConfig(),
        _repository.getApplications(),
        _repository.getCategories(),
        _repository.getTransactions(),
        _repository.getOutlets(),
        _repository.getPromotions(),
        _repository.getNotifications(),
        _repository.getFaqs(),
      ]);
      _simulationConfig = results[0] as SimulationConfig;
      _applications = results[1] as List<PawnApplication>;
      _categories = results[2] as List<PawnCategoryInfo>;
      _transactions = results[3] as List<PawnTransaction>;
      _outlets = results[4] as List<OutletInfo>;
      _promotions = results[5] as List<PromoInfo>;
      _notifications = results[6] as List<AppNotification>;
      _faqs = results[7] as List<FaqItem>;
    } catch (e) {
      _dataError = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoadingData = false;
      notifyListeners();
    }
  }

  Future<PawnApplication> submitApplication({
    required PawnCategory category,
    required String itemTitle,
    required Map<String, String> itemDetails,
    required List<PawnDocument> documents,
    double? estimatedValue,
    int? preferredTenorDays,
  }) async {
    final created = await _repository.submitApplication(
      category: category,
      itemTitle: itemTitle,
      itemDetails: itemDetails,
      documents: documents,
      estimatedValue: estimatedValue,
      preferredTenorDays: preferredTenorDays,
    );
    _applications = await _repository.getApplications();
    _notifications = await _repository.getNotifications();
    notifyListeners();
    return created;
  }

  Future<PawnApplication> reviseApplication({
    required String applicationId,
    required String itemTitle,
    required Map<String, String> itemDetails,
    required List<PawnDocument> documents,
  }) async {
    final updated = await _repository.reviseApplication(
      applicationId: applicationId,
      itemTitle: itemTitle,
      itemDetails: itemDetails,
      documents: documents,
    );
    _applications = await _repository.getApplications();
    notifyListeners();
    return updated;
  }

  Future<PawnTransaction> acceptOffer(String applicationId) async {
    final trx = await _repository.acceptOffer(applicationId);
    _applications = await _repository.getApplications();
    _transactions = await _repository.getTransactions();
    notifyListeners();
    return trx;
  }

  Future<void> declineOffer(String applicationId) async {
    await _repository.declineOffer(applicationId);
    _applications = await _repository.getApplications();
    notifyListeners();
  }

  Future<PawnTransaction> recordDemoPayment({
    required String transactionId,
    required double amount,
    required String method,
  }) async {
    final updated = await _repository.recordDemoPayment(
      transactionId: transactionId,
      amount: amount,
      method: method,
    );
    _transactions = await _repository.getTransactions();
    notifyListeners();
    return updated;
  }

  Future<void> markNotificationRead(String notificationId) async {
    await _repository.markNotificationRead(notificationId);
    _notifications = await _repository.getNotifications();
    notifyListeners();
  }

  PawnApplication? findApplicationById(String id) {
    for (final app in _applications) {
      if (app.id == id) return app;
    }
    return null;
  }

  PawnTransaction? findTransactionById(String id) {
    for (final trx in _transactions) {
      if (trx.id == id) return trx;
    }
    return null;
  }
}

/// InheritedNotifier scope for accessing [AppState] across the widget tree.
class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required AppState state,
    required super.child,
  }) : super(notifier: state);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'AppStateScope not found in widget tree.');
    return scope!.notifier!;
  }

  /// Aman dipakai dari widget yang mungkin berada di route overlay.
  static AppState? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<AppStateScope>()
        ?.notifier;
  }
}
