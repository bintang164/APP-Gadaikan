import 'package:flutter/material.dart';
import '../models/gadaikan_models.dart';
import '../services/gadaikan_repository.dart';

/// Central application state coordinator backed by [GadaikanRepository].
class AppState extends ChangeNotifier {
  AppState(this._repository);

  final GadaikanRepository _repository;

  UserProfile? _user;
  SimulationConfig? _simulationConfig;
  List<PawnApplication> _applications = const [];
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
  List<PawnApplication> get applications => _applications;
  List<PawnTransaction> get transactions => _transactions;
  List<OutletInfo> get outlets => _outlets;
  List<PromoInfo> get promotions => _promotions;
  List<AppNotification> get notifications => _notifications;
  List<FaqItem> get faqs => _faqs;
  bool get isLoadingData => _isLoadingData;
  String? get dataError => _dataError;

  int get unreadNotificationCount =>
      _notifications.where((n) => !n.isRead).length;

  int get pendingApplicationCount =>
      _applications.where((a) => a.status.isPendingAction).length;

  void completeOnboarding() {
    _hasSeenOnboarding = true;
    notifyListeners();
  }

  Future<bool> initialize() async {
    _user = await _repository.restoreSession();
    _simulationConfig = await _repository.getSimulationConfig();
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
        _repository.getTransactions(),
        _repository.getOutlets(),
        _repository.getPromotions(),
        _repository.getNotifications(),
        _repository.getFaqs(),
      ]);
      _simulationConfig = results[0] as SimulationConfig;
      _applications = results[1] as List<PawnApplication>;
      _transactions = results[2] as List<PawnTransaction>;
      _outlets = results[3] as List<OutletInfo>;
      _promotions = results[4] as List<PromoInfo>;
      _notifications = results[5] as List<AppNotification>;
      _faqs = results[6] as List<FaqItem>;
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

  Future<PawnApplication> simulateReviewDecision({
    required String applicationId,
    required ApplicationStatus nextStatus,
    String? note,
  }) async {
    final updated = await _repository.simulateReviewDecision(
      applicationId: applicationId,
      nextStatus: nextStatus,
      note: note,
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
}
