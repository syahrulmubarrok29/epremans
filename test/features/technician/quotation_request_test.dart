import 'package:epremans/core/exceptions/app_exception.dart';
import 'package:epremans/data/local/datasources/local_data_source.dart';
import 'package:epremans/data/repositories/quotation_request_repository.dart';
import 'package:epremans/models/quotation_request_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('QuotationRequestModel', () {
    test('toMap and fromMap round trip', () {
      final createdAt = DateTime.now();
      final updatedAt = createdAt.add(const Duration(hours: 1));

      final model = QuotationRequestModel(
        id: 10,
        technicianId: 7,
        relatedTaskId: 3,
        title: 'Replacement quote',
        description: 'Need spare parts for calibration',
        estimatedCost: 2500000.0,
        status: 'Draft',
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      final map = model.toMap();
      final roundTripped = QuotationRequestModel.fromMap(map);

      expect(roundTripped.id, 10);
      expect(roundTripped.technicianId, 7);
      expect(roundTripped.relatedTaskId, 3);
      expect(roundTripped.title, 'Replacement quote');
      expect(roundTripped.description, 'Need spare parts for calibration');
      expect(roundTripped.estimatedCost, 2500000.0);
      expect(roundTripped.status, 'Draft');
    });
  });

  group('QuotationRequestRepository', () {
    late QuotationRequestRepository repo;

    setUp(() {
      repo = QuotationRequestRepository(localDataSource: LocalDataSource());
    });

    test('create quotation request persists and returns saved record', () async {
      final request = QuotationRequestModel(
        id: 0,
        technicianId: 1,
        relatedTaskId: 1,
        title: 'Spare part quotation',
        description: 'Replacement cable and sensor set',
        estimatedCost: 1250000.0,
        status: 'Draft',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final created = await repo.createQuotationRequest(request);
      expect(created.id, greaterThan(0));
      expect(created.technicianId, 1);
      expect(created.title, 'Spare part quotation');
      expect(created.status, 'Draft');
    });

    test('read quotation requests returns only technician owned items', () async {
      final requests = await repo.getQuotationRequestsByTechnician(1);
      expect(requests, isNotEmpty);
      expect(requests.every((r) => r.technicianId == 1), isTrue);
    });

    test('update quotation request updates stored values', () async {
      final created = await repo.createQuotationRequest(
        QuotationRequestModel(
          id: 0,
          technicianId: 1,
          relatedTaskId: 1,
          title: 'Initial estimate',
          description: 'For device repair',
          estimatedCost: 900000.0,
          status: 'Draft',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      final updated = await repo.updateQuotationRequest(
        created.copyWith(
          title: 'Updated estimate',
          description: 'Updated repair scope',
          estimatedCost: 1100000.0,
        ),
        1,
      );

      expect(updated.title, 'Updated estimate');
      expect(updated.description, 'Updated repair scope');
      expect(updated.estimatedCost, 1100000.0);
    });

    test('delete quotation request removes record', () async {
      final created = await repo.createQuotationRequest(
        QuotationRequestModel(
          id: 0,
          technicianId: 1,
          relatedTaskId: 1,
          title: 'To delete',
          description: 'Temporary record',
          estimatedCost: 400000.0,
          status: 'Draft',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      await repo.deleteQuotationRequest(created.id, 1);
      expect(
        () => repo.getQuotationRequestById(created.id, 1),
        throwsA(isA<LocalNotFoundException>()),
      );
    });

    test('prevent another technician from accessing the request', () async {
      final created = await repo.createQuotationRequest(
        QuotationRequestModel(
          id: 0,
          technicianId: 1,
          relatedTaskId: 1,
          title: 'Private quote',
          description: 'Should not be visible to another tech',
          estimatedCost: 200000.0,
          status: 'Draft',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      expect(
        () => repo.getQuotationRequestById(created.id, 2),
        throwsA(isA<UnauthorizedException>()),
      );
    });

    test('form validation rejects negative total cost', () async {
      expect(
        () => repo.createQuotationRequest(
          QuotationRequestModel(
            id: 0,
            technicianId: 1,
            relatedTaskId: 1,
            title: 'Bad quote',
            description: 'Negative value',
            estimatedCost: -100.0,
            status: 'Draft',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ),
        throwsA(isA<ValidationException>()),
      );
    });
  });
}
