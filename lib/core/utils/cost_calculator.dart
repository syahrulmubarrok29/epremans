import '../../models/service_report_part_model.dart';

/// Reusable calculation layer for Service Report Cost fields.
/// Ensures no hardcoded rates and standardizes the math across the app.
class CostCalculator {
  CostCalculator._();

  /// Calculates the labor subtotal: (Labor Time in Hours) × (Labor Rate)
  static double calculateLaborSubtotal({
    required double laborTimeHours,
    required double laborRate,
  }) {
    if (laborTimeHours < 0 || laborRate < 0) return 0.0;
    return laborTimeHours * laborRate;
  }

  /// Calculates the travel subtotal: (Travel Time in Hours) × (Travel Rate)
  static double calculateTravelSubtotal({
    required double travelTimeHours,
    required double travelRate,
  }) {
    if (travelTimeHours < 0 || travelRate < 0) return 0.0;
    return travelTimeHours * travelRate;
  }

  /// Calculates the parts total: Sum of (Quantity × Unit Price) for all parts
  static double calculatePartsTotal(List<ServiceReportPartModel> parts) {
    return parts.fold(0.0, (sum, part) {
      if (part.quantity < 0 || part.unitPrice < 0) return sum;
      return sum + part.total;
    });
  }

  /// Calculates the total service cost.
  static double calculateTotalCost({
    required double laborSubtotal,
    required double travelSubtotal,
    required double partsTotal,
    double travelCost = 0.0,
    double othersCost = 0.0,
  }) {
    final tCost = travelCost < 0 ? 0.0 : travelCost;
    final oCost = othersCost < 0 ? 0.0 : othersCost;
    
    return laborSubtotal + travelSubtotal + partsTotal + tCost + oCost;
  }
}
