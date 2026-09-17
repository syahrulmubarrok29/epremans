import 'package:epremans/models/service_report_model.dart';
import 'package:epremans/models/service_report_part_model.dart';
import 'package:epremans/models/technician_task_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TechnicianTaskModel Serialization', () {
    test('fromJson and toJson work correctly', () {
      final now = DateTime(2026, 9, 17, 8, 0, 0);
      final task = TechnicianTaskModel(
        id: 1,
        serviceRequestId: 10,
        technicianId: 5,
        assignedAt: now,
        status: 'Assigned',
        customerName: 'RS Sehat',
      );

      final json = task.toJson();
      expect(json['id'], 1);
      expect(json['status'], 'Assigned');
      expect(json['customer_name'], 'RS Sehat');

      final fromJson = TechnicianTaskModel.fromJson(json);
      expect(fromJson.id, task.id);
      expect(fromJson.status, task.status);
      expect(fromJson.assignedAt, task.assignedAt);
    });
  });

  group('ServiceReportModel Serialization', () {
    test('fromJson and toJson handle parts correctly', () {
      final parts = [
        const ServiceReportPartModel(
          id: 1,
          serviceReportId: 100,
          partNumber: 'PN-123',
          partDescription: 'Test Part',
          quantity: 2,
          unitPrice: 50000.0,
        ),
      ];

      final report = ServiceReportModel(
        id: 100,
        taskId: 1,
        technicianId: 1,
        customerName: 'Customer',
        customerAddress: 'Address',
        brand: 'Brand',
        typeModel: 'Type',
        serialNumber: 'SN-123',
        location: 'Room 1',
        serviceType: 'Corrective',
        parts: parts,
      );

      final json = report.toJson();
      expect(json['id'], 100);
      expect(json['parts_total'], 100000.0); // 2 * 50000.0

      final fromJson = ServiceReportModel.fromJson(json);
      expect(fromJson.parts.length, 1);
      expect(fromJson.parts.first.partNumber, 'PN-123');
    });
  });
}
