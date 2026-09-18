import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:epremans/models/service_report_model.dart';
import 'package:epremans/models/service_report_part_model.dart';
import 'package:epremans/data/repositories/service_report_repository.dart';
import 'package:epremans/data/providers/data_providers.dart';

final serviceReportFormProvider = StateNotifierProvider<ServiceReportFormController, ServiceReportModel?>((ref) {
  final repository = ref.read(serviceReportRepositoryProvider);
  return ServiceReportFormController(repository: repository);
});

class ServiceReportFormController extends StateNotifier<ServiceReportModel?> {
  ServiceReportFormController({required this.repository}) : super(null);

  final ServiceReportRepository repository;

  /// Initializes a new service report for the given task and technician.
  void initializeReport({
    required int taskId,
    required int technicianId,
    String? customerName,
    String? customerAddress,
    String? brand,
    String? typeModel,
    String? serialNumber,
    String? location,
  }) {
    state = ServiceReportModel(
      id: 0, // 0 indicates it's a new report (unsaved)
      taskId: taskId,
      technicianId: technicianId,
      customerName: customerName ?? '',
      customerAddress: customerAddress ?? '',
      brand: brand ?? '',
      typeModel: typeModel ?? '',
      serialNumber: serialNumber ?? '',
      location: location ?? '',
      serviceType: 'Preventive', // Default
    );
  }

  void updateEquipmentInfo({
    required String customerName,
    required String customerAddress,
    required String brand,
    required String typeModel,
    required String serialNumber,
    required String location,
    required String serviceType,
  }) {
    if (state == null) return;
    state = state!.copyWith(
      customerName: customerName,
      customerAddress: customerAddress,
      brand: brand,
      typeModel: typeModel,
      serialNumber: serialNumber,
      location: location,
      serviceType: serviceType,
    );
  }

  void updateServiceBegin(DateTime begin) {
    if (state == null) return;
    state = state!.copyWith(serviceBegin: begin);
  }

  void updateProblemSolution({
    required String problem,
    required String solutions,
    required String remarks,
    required String workStatus,
  }) {
    if (state == null) return;
    state = state!.copyWith(
      problem: problem,
      solutions: solutions,
      remarks: remarks,
      workStatus: workStatus,
    );
  }

  void addPart(ServiceReportPartModel part) {
    if (state == null) return;
    final currentParts = List<ServiceReportPartModel>.from(state!.parts);
    currentParts.add(part);
    state = state!.copyWith(parts: currentParts);
  }

  void removePart(int index) {
    if (state == null) return;
    final currentParts = List<ServiceReportPartModel>.from(state!.parts);
    if (index >= 0 && index < currentParts.length) {
      currentParts.removeAt(index);
      state = state!.copyWith(parts: currentParts);
    }
  }

  void updateCosts({
    double? laborTimeHours,
    double? laborRate,
    double? travelTimeHours,
    double? travelRate,
    double? travelCost,
    double? othersCost,
  }) {
    if (state == null) return;
    state = state!.copyWith(
      laborTimeHours: laborTimeHours,
      laborRate: laborRate,
      travelTimeHours: travelTimeHours,
      travelRate: travelRate,
      travelCost: travelCost,
      othersCost: othersCost,
    );
  }

  void updateServiceEnd(DateTime end) {
    if (state == null) return;
    state = state!.copyWith(serviceEnd: end);
  }

  void updateSignatures({
    required String technicianSignatureData,
    required String customerSignatureData,
  }) {
    if (state == null) return;
    state = state!.copyWith(
      technicianSignatureData: technicianSignatureData,
      customerSignatureData: customerSignatureData,
    );
  }

  /// Submits the final report to the repository.
  Future<void> submitReport() async {
    if (state == null) throw Exception("No active report.");

    // Basic validation
    if (state!.serviceBegin == null) throw Exception("Service Begin is missing.");
    if (state!.serviceEnd == null) throw Exception("Service End is missing.");
    if (state!.technicianSignatureData == null || state!.customerSignatureData == null) {
      throw Exception("Signatures are missing.");
    }

    await repository.saveReportLocally(state!);

    // Match the expected controller contract: the in-memory report is cleared
    // after a successful save so the workflow can restart cleanly.
    state = null;
  }
}
