import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/exceptions/app_exception.dart';
import '../../../../data/providers/data_providers.dart';
import '../../../../models/quotation_request_model.dart';

class QuotationRequestState {
  const QuotationRequestState({
    this.requests = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.errorMessage,
  });

  final List<QuotationRequestModel> requests;
  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;

  QuotationRequestState copyWith({
    List<QuotationRequestModel>? requests,
    bool? isLoading,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return QuotationRequestState(
      requests: requests ?? this.requests,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
    );
  }
}

class QuotationRequestController extends StateNotifier<QuotationRequestState> {
  QuotationRequestController(this._ref) : super(const QuotationRequestState());

  final Ref _ref;

  Future<void> loadRequests(int technicianId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repo = _ref.read(quotationRequestRepositoryProvider);
      final requests = await repo.getQuotationRequestsByTechnician(technicianId);
      state = state.copyWith(requests: requests, isLoading: false, errorMessage: null);
    } on AppException catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.message);
    } catch (_) {
      state = state.copyWith(isLoading: false, errorMessage: 'Unable to load quotation requests.');
    }
  }

  Future<void> createRequest(int technicianId, QuotationRequestModel request) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      final repo = _ref.read(quotationRequestRepositoryProvider);
      await repo.createQuotationRequest(request.copyWith(technicianId: technicianId));
      await loadRequests(technicianId);
    } on AppException catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.message);
      rethrow;
    } catch (_) {
      state = state.copyWith(isSubmitting: false, errorMessage: 'Unable to create quotation request.');
      rethrow;
    }
  }

  Future<void> updateRequest(int technicianId, QuotationRequestModel request) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      final repo = _ref.read(quotationRequestRepositoryProvider);
      await repo.updateQuotationRequest(request, technicianId);
      await loadRequests(technicianId);
    } on AppException catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.message);
      rethrow;
    } catch (_) {
      state = state.copyWith(isSubmitting: false, errorMessage: 'Unable to update quotation request.');
      rethrow;
    }
  }

  Future<void> deleteRequest(int technicianId, int requestId) async {
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    try {
      final repo = _ref.read(quotationRequestRepositoryProvider);
      await repo.deleteQuotationRequest(requestId, technicianId);
      final updated = state.requests.where((r) => r.id != requestId).toList();
      state = state.copyWith(requests: updated, isSubmitting: false, errorMessage: null);
    } on AppException catch (e) {
      state = state.copyWith(isSubmitting: false, errorMessage: e.message);
      rethrow;
    } catch (_) {
      state = state.copyWith(isSubmitting: false, errorMessage: 'Unable to delete quotation request.');
      rethrow;
    }
  }

  Future<void> refreshRequests(int technicianId) async {
    await loadRequests(technicianId);
  }
}

final quotationRequestControllerProvider =
    StateNotifierProvider<QuotationRequestController, QuotationRequestState>((ref) {
  return QuotationRequestController(ref);
});
