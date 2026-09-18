import '../../core/exceptions/app_exception.dart';
import '../../data/mock/datasources/mock_data_source.dart';
import '../../models/quotation_request_model.dart';
import '../local/datasources/local_data_source.dart';

class QuotationRequestRepository {
  QuotationRequestRepository({required this.localDataSource});

  final LocalDataSource localDataSource;

  Future<List<QuotationRequestModel>> getQuotationRequestsByTechnician(int technicianId) async {
    try {
      final local = await localDataSource.getQuotationRequestsByTechnician(technicianId);
      if (local.isNotEmpty) return local;
    } on AppException {
      rethrow;
    } catch (_) {
      throw DatabaseException('Failed to read quotation requests.');
    }

    final mockRequests = MockDataSource.quotationRequests
        .where((request) => request.technicianId == technicianId)
        .toList();

    if (mockRequests.isEmpty) return const [];

    for (final request in mockRequests) {
      try {
        await localDataSource.insertQuotationRequest(request);
      } on AppException {
        rethrow;
      } catch (_) {
        throw DatabaseException('Failed to seed quotation request data locally.');
      }
    }

    return mockRequests;
  }

  Future<QuotationRequestModel> getQuotationRequestById(int id, int technicianId) async {
    try {
      final request = await localDataSource.getQuotationRequestById(id);
      if (request == null) {
        throw LocalNotFoundException('Quotation request not found.');
      }
      if (request.technicianId != technicianId) {
        throw UnauthorizedException('You are not allowed to access this quotation request.');
      }
      return request;
    } on AppException {
      rethrow;
    } catch (_) {
      throw DatabaseException('Failed to load quotation request.');
    }
  }

  Future<QuotationRequestModel> createQuotationRequest(QuotationRequestModel request) async {
    if (request.relatedTaskId <= 0) {
      throw ValidationException('Related task is required.');
    }
    if (request.title.trim().isEmpty) {
      throw ValidationException('Title is required.');
    }
    if (request.description.trim().isEmpty) {
      throw ValidationException('Description is required.');
    }
    if (request.estimatedCost < 0) {
      throw ValidationException('Estimated cost must be a valid non-negative number.');
    }
    if (request.status.trim().isEmpty) {
      request = request.copyWith(status: 'Draft');
    }

    final created = request.copyWith(
      createdAt: request.createdAt,
      updatedAt: request.updatedAt,
    );

    try {
      final id = await localDataSource.insertQuotationRequest(created);
      return created.copyWith(id: id);
    } on AppException {
      rethrow;
    } catch (_) {
      throw DatabaseException('Failed to create quotation request.');
    }
  }

  Future<QuotationRequestModel> updateQuotationRequest(QuotationRequestModel request, int technicianId) async {
    final existing = await getQuotationRequestById(request.id, technicianId);
    if (existing.technicianId != technicianId) {
      throw UnauthorizedException('You are not allowed to edit this quotation request.');
    }

    if (request.relatedTaskId <= 0) {
      throw ValidationException('Related task is required.');
    }
    if (request.title.trim().isEmpty) {
      throw ValidationException('Title is required.');
    }
    if (request.description.trim().isEmpty) {
      throw ValidationException('Description is required.');
    }
    if (request.estimatedCost < 0) {
      throw ValidationException('Estimated cost must be a valid non-negative number.');
    }

    final updated = request.copyWith(
      technicianId: technicianId,
      updatedAt: DateTime.now(),
    );

    try {
      final rows = await localDataSource.updateQuotationRequest(updated, technicianId);
      if (rows == 0) {
        throw DatabaseException('Failed to update quotation request.');
      }
      return updated;
    } on AppException {
      rethrow;
    } catch (_) {
      throw DatabaseException('Failed to update quotation request.');
    }
  }

  Future<void> deleteQuotationRequest(int id, int technicianId) async {
    final existing = await getQuotationRequestById(id, technicianId);
    if (existing.technicianId != technicianId) {
      throw UnauthorizedException('You are not allowed to delete this quotation request.');
    }

    try {
      final rows = await localDataSource.deleteQuotationRequest(id, technicianId: technicianId);
      if (rows == 0) {
        throw DatabaseException('Failed to delete quotation request.');
      }
    } on AppException {
      rethrow;
    } catch (_) {
      throw DatabaseException('Failed to delete quotation request.');
    }
  }
}
