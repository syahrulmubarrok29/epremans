import 'package:epremans/core/utils/cost_calculator.dart';
import 'package:epremans/models/service_report_part_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CostCalculator', () {
    test('Calculates labor subtotal correctly', () {
      expect(
        CostCalculator.calculateLaborSubtotal(laborTimeHours: 2, laborRate: 200000),
        400000.0,
      );
    });

    test('Returns 0 for negative labor inputs', () {
      expect(
        CostCalculator.calculateLaborSubtotal(laborTimeHours: -1, laborRate: 200000),
        0.0,
      );
    });

    test('Calculates parts total correctly', () {
      final parts = [
        const ServiceReportPartModel(
          id: 1,
          serviceReportId: 1,
          partNumber: 'A',
          partDescription: 'Part A',
          quantity: 2,
          unitPrice: 50000,
        ),
        const ServiceReportPartModel(
          id: 2,
          serviceReportId: 1,
          partNumber: 'B',
          partDescription: 'Part B',
          quantity: 1,
          unitPrice: 100000,
        ),
      ];

      expect(CostCalculator.calculatePartsTotal(parts), 200000.0);
    });

    test('Calculates total cost correctly', () {
      final total = CostCalculator.calculateTotalCost(
        laborSubtotal: 400000,
        travelSubtotal: 100000,
        partsTotal: 200000,
        travelCost: 50000,
        othersCost: 25000,
      );

      expect(total, 775000.0);
    });
  });
}
