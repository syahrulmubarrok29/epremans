import '../../../core/constants/app_constants.dart';
import '../../../models/customer_model.dart';
import '../../../models/equipment_model.dart';
import '../../../models/service_report_model.dart';
import '../../../models/service_report_part_model.dart';
import '../../../models/service_request_model.dart';
import '../../../models/technician_task_model.dart';
import '../../../models/user_model.dart';

/// Provides realistic mock data for UI development before the API is ready.
class MockDataSource {
  MockDataSource._();

  // ---------------------------------------------------------------------------
  // Mock Credentials (Phase 3 — plain-string, prototype only)
  // Passwords exist ONLY here. Never stored in UserModel or auth state.
  // Replace entirely during Laravel API integration.
  // ---------------------------------------------------------------------------
  static const Map<String, String> _credentials = {
    'admin@rssehat.com': 'password123', // Customer account
    'tech@polaris.com': 'password123',  // Technician account
  };

  /// Returns the matching [UserModel] if [email] + [password] match,
  /// or `null` if credentials are invalid.
  ///
  /// Phase 3 prototype — plain-string comparison, no hashing.
  /// Replace with API call during Laravel integration.
  static UserModel? findByCredentials(String email, String password) {
    if (_credentials[email] != password) return null;
    try {
      return users.firstWhere((u) => u.email == email);
    } on StateError {
      // Credential map is out of sync with users list — should never happen.
      assert(false, 'MockDataSource: credential entry "$email" has no matching user.');
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Users
  // ---------------------------------------------------------------------------
  static final List<UserModel> users = [
    const UserModel(
      id: 1,
      name: 'John Technician',
      email: 'tech@polaris.com',
      role: AppConstants.roleTechnician,
      phone: '+628123456789',
    ),
    const UserModel(
      id: 2,
      name: 'Jane Hospital Admin',
      email: 'admin@rssehat.com',
      role: AppConstants.roleCustomer,
      phone: '+628987654321',
    ),
  ];

  // ---------------------------------------------------------------------------
  // Customers
  // ---------------------------------------------------------------------------
  static final List<CustomerModel> customers = [
    const CustomerModel(
      id: 1,
      name: 'RS Sehat Selalu',
      address: 'Jl. Kesehatan No. 1, Jakarta Selatan',
      phone: '021-123456',
      contactPerson: 'Jane Hospital Admin',
    ),
    const CustomerModel(
      id: 2,
      name: 'Klinik Cahaya',
      address: 'Jl. Terang No. 99, Bandung',
      phone: '022-654321',
      contactPerson: 'Dr. Surya',
    ),
  ];

  // ---------------------------------------------------------------------------
  // Equipment
  // ---------------------------------------------------------------------------
  static final List<EquipmentModel> equipment = [
    const EquipmentModel(
      id: 1,
      brand: 'Polaris',
      typeModel: 'X-Ray 5000',
      serialNumber: 'SN-XR-5000-001',
      location: 'Radiology Room 1',
      customerId: 1,
      customerName: 'RS Sehat Selalu',
      customerAddress: 'Jl. Kesehatan No. 1, Jakarta Selatan',
      qrCode: 'QR-POLARIS-001',
    ),
    const EquipmentModel(
      id: 2,
      brand: 'Polaris',
      typeModel: 'Ultrasound V2',
      serialNumber: 'SN-US-V2-045',
      location: 'OBGYN Clinic',
      customerId: 2,
      customerName: 'Klinik Cahaya',
      customerAddress: 'Jl. Terang No. 99, Bandung',
      qrCode: 'QR-POLARIS-002',
    ),
  ];

  // ---------------------------------------------------------------------------
  // Service Requests (Damage Reports)
  // ---------------------------------------------------------------------------
  static final List<ServiceRequestModel> serviceRequests = [
    ServiceRequestModel(
      id: 1,
      ticketNumber: 'REQ-202609-001',
      customerId: 1,
      equipmentId: 1,
      problemDescription: 'X-Ray monitor flickers during scans.',
      status: 'In Progress',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      customerName: 'RS Sehat Selalu',
      equipmentBrand: 'Polaris',
      equipmentModel: 'X-Ray 5000',
      technicianId: 1,
      technicianName: 'John Technician',
    ),
    ServiceRequestModel(
      id: 2,
      ticketNumber: 'REQ-202609-002',
      customerId: 2,
      equipmentId: 2,
      problemDescription: 'Probe button unresponsive.',
      status: 'Pending',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      customerName: 'Klinik Cahaya',
      equipmentBrand: 'Polaris',
      equipmentModel: 'Ultrasound V2',
    ),
  ];

  // ---------------------------------------------------------------------------
  // Technician Tasks
  // ---------------------------------------------------------------------------
  static final List<TechnicianTaskModel> technicianTasks = [
    TechnicianTaskModel(
      id: 1,
      serviceRequestId: 1,
      technicianId: 1,
      assignedAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      status: 'Assigned',
      customerName: 'RS Sehat Selalu',
      customerAddress: 'Jl. Kesehatan No. 1, Jakarta Selatan',
      equipmentBrand: 'Polaris',
      equipmentModel: 'X-Ray 5000',
      problemDescription: 'X-Ray monitor flickers during scans.',
    ),
  ];

  // ---------------------------------------------------------------------------
  // Service Reports
  // ---------------------------------------------------------------------------
  static final List<ServiceReportModel> serviceReports = [
    ServiceReportModel(
      id: 1,
      taskId: 1,
      technicianId: 1,
      customerName: 'RS Sehat Selalu',
      customerAddress: 'Jl. Kesehatan No. 1, Jakarta Selatan',
      brand: 'Polaris',
      typeModel: 'X-Ray 5000',
      serialNumber: 'SN-XR-5000-001',
      location: 'Radiology Room 1',
      serviceType: 'Corrective',
      serviceBegin: DateTime.now().subtract(const Duration(hours: 3)),
      serviceEnd: DateTime.now().subtract(const Duration(hours: 1)),
      problem: 'X-Ray monitor flickers during scans.',
      solutions: 'Replaced internal power supply module and calibrated display.',
      remarks: 'Operational normal.',
      workStatus: 'Completed',
      parts: [
        const ServiceReportPartModel(
          id: 1,
          serviceReportId: 1,
          partNumber: 'PN-PSU-001',
          partDescription: 'Power Supply Module 500W',
          quantity: 1,
          unitPrice: 1500000.0,
        ),
      ],
      laborTimeHours: 2.0,
      laborRate: 200000.0,
      travelTimeHours: 1.5,
      travelRate: 50000.0,
      travelCost: 75000.0,
      othersCost: 20000.0,
    ),
  ];
}
