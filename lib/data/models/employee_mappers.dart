import '../../domain/entities/employee.dart';

/// `EmployeeResource` ↔ [Employee]. Endpoint/field names are a best guess
/// following the rest of the app's convention — not yet confirmed against a
/// running backend.
const Map<String, EmploymentStatus> _statusFromApi = {
  'active': EmploymentStatus.active,
  'on_leave': EmploymentStatus.onLeave,
  'inactive': EmploymentStatus.inactive,
  'terminated': EmploymentStatus.inactive,
};

Employee employeeFromJson(Map<String, dynamic> json) {
  final designation = json['designation'];
  final department = json['department'];

  return Employee(
    id: json['id'].toString(),
    name: json['name'] as String? ?? json['full_name'] as String? ?? '',
    status: _statusFromApi[json['status']] ?? EmploymentStatus.active,
    designation: designation is Map
        ? designation['name'] as String?
        : designation as String?,
    department: department is Map
        ? department['name'] as String?
        : department as String?,
    phone: json['phone'] as String?,
    email: json['email'] as String?,
  );
}
