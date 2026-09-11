import '../../domain/entities/invoice.dart';

/// `InvoiceResource` ↔ [Invoice]. Endpoint/field names are a best guess
/// following the rest of the app's convention (snake_case, `amount` fields as
/// numeric strings or numbers) — not yet confirmed against a running backend.
/// Adjust here only; nothing above the data layer needs to change.
const Map<String, InvoiceStatus> _statusFromApi = {
  'unpaid': InvoiceStatus.unpaid,
  'partially_paid': InvoiceStatus.partial,
  'partial': InvoiceStatus.partial,
  'paid': InvoiceStatus.paid,
  'overdue': InvoiceStatus.overdue,
  'cancelled': InvoiceStatus.cancelled,
  'void': InvoiceStatus.cancelled,
};

const Map<InvoiceStatus, String> invoiceStatusToApi = {
  InvoiceStatus.unpaid: 'unpaid',
  InvoiceStatus.partial: 'partially_paid',
  InvoiceStatus.paid: 'paid',
  InvoiceStatus.overdue: 'overdue',
  InvoiceStatus.cancelled: 'cancelled',
};

num _money(dynamic v) => v is num ? v : num.tryParse(v?.toString() ?? '') ?? 0;

DateTime _date(dynamic v) =>
    DateTime.tryParse(v?.toString() ?? '') ?? DateTime.now();

InvoicePayment invoicePaymentFromJson(Map<String, dynamic> json) {
  return InvoicePayment(
    id: json['id'].toString(),
    amount: _money(json['amount']),
    method:
        json['method'] as String? ?? json['payment_method'] as String? ?? '',
    paidAt: _date(json['paid_at'] ?? json['created_at']),
    note: json['note'] as String?,
  );
}

Invoice invoiceFromJson(Map<String, dynamic> json) {
  final customer = json['customer'];
  final booking = json['booking'];
  final payments = json['payments'];

  return Invoice(
    id: json['id'].toString(),
    reference:
        json['invoice_number'] as String? ?? json['reference'] as String? ?? '',
    customerName:
        (customer is Map ? customer['name'] as String? : null) ??
        json['customer_name'] as String? ??
        '',
    amount: _money(json['total_amount'] ?? json['amount']),
    paidAmount: _money(json['paid_amount']),
    dueDate: _date(json['due_date']),
    status: _statusFromApi[json['status']] ?? InvoiceStatus.unpaid,
    bookingReference:
        (booking is Map ? booking['pnr'] as String? : null) ??
        json['booking_reference'] as String?,
    payments: payments is List
        ? payments
              .whereType<Map<dynamic, dynamic>>()
              .map((p) => invoicePaymentFromJson(p.cast<String, dynamic>()))
              .toList(growable: false)
        : const [],
  );
}
