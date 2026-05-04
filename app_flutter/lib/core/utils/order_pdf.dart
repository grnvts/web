import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class OrderPdfBuilder {
  static Future<Uint8List> build({
    required Map<String, dynamic> order,
    required List<dynamic> masters,
    String? generatedBy,
  }) async {
    final document = pw.Document();
    final now = DateTime.now();
    final formattedNow = DateFormat('dd.MM.yyyy HH:mm').format(now);

    final status = _safe(order['status']);
    final orderId = _safe(order['id']);
    final createdDate = _formatDate(order['createdDate']?.toString());
    final startDate = _formatDate(order['startDate']?.toString());
    final endDate = _formatDate(order['endDate']?.toString());
    final price = _safe(order['price'], fallback: '0');

    document.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          theme: pw.ThemeData.withFont(
            base: pw.Font.helvetica(),
            bold: pw.Font.helveticaBold(),
          ),
          margin: const pw.EdgeInsets.all(32),
        ),
        build: (context) => <pw.Widget>[
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: <pw.Widget>[
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: <pw.Widget>[
                    pw.Text(
                      'Order #$orderId',
                      style: pw.TextStyle(
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    pw.Text(
                      'Status: ${_statusLabel(status)}',
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                    pw.Text(
                      'Created: $createdDate',
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: pw.BoxDecoration(
                  color: PdfColors.teal50,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Text(
                  'Generated $formattedNow',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          _sectionTitle('Order details'),
          _infoRow('Service type', _serviceTypeLabel(order['serviceType'])),
          _infoRow('Work details', _safe(order['orderDetails'])),
          _infoRow('Address', _formatAddress(order['address'])),
          _infoRow('Start date', startDate),
          _infoRow('End date', endDate),
          _infoRow('Price', '$price BYN'),
          pw.SizedBox(height: 16),
          _sectionTitle('Client and brigade'),
          _infoRow('Client', _clientLabel(order)),
          _infoRow('Client username', _safe(order['clientUsername'])),
          _infoRow('Client phone', _safe(order['clientPhone'])),
          _infoRow('Brigadier', _brigadierLabel(order)),
          _infoRow('Brigadier username', _safe(order['brigadierUsername'])),
          _infoRow('Brigade number', _safe(order['brigadeNumber'])),
          pw.SizedBox(height: 16),
          _sectionTitle('Assigned masters'),
          masters.isEmpty
              ? pw.Text(
                  'No masters assigned.',
                  style: const pw.TextStyle(fontSize: 12),
                )
              : pw.Column(
                  children: masters.map(
                    (master) {
                      final masterMap = master is Map<String, dynamic>
                          ? master
                          : <String, dynamic>{};
                      return pw.Container(
                        margin: const pw.EdgeInsets.only(bottom: 6),
                        child: pw.Row(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: <pw.Widget>[
                            pw.Expanded(
                              child: pw.Text(
                                _personLabel(masterMap),
                                style: const pw.TextStyle(fontSize: 12),
                              ),
                            ),
                            if (_hasValue(masterMap['phone']))
                              pw.Text(
                                masterMap['phone'].toString(),
                                style: const pw.TextStyle(fontSize: 11),
                              ),
                          ],
                        ),
                      );
                    },
                  ).toList(growable: false),
                ),
          if (generatedBy != null && generatedBy.trim().isNotEmpty) ...[
            pw.SizedBox(height: 24),
            pw.Divider(color: PdfColors.grey300),
            pw.Text(
              'Generated by $generatedBy',
              style: const pw.TextStyle(fontSize: 10),
            ),
          ],
        ],
      ),
    );

    return document.save();
  }

  static pw.Widget _sectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 14,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.teal700,
        ),
      ),
    );
  }

  static pw.Widget _infoRow(String label, String value) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.SizedBox(
            width: 140,
            child: pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 11,
                color: PdfColors.grey700,
              ),
            ),
          ),
          pw.Expanded(
            child: pw.Text(
              value.isEmpty ? 'Not set' : value,
              style: const pw.TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  static String _safe(dynamic value, {String fallback = 'Not set'}) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }

  static bool _hasValue(dynamic value) {
    if (value == null) return false;
    return value.toString().trim().isNotEmpty;
  }

  static String _formatDate(String? value) {
    if (value == null || value.trim().isEmpty) return 'Not set';
    try {
      final date = DateTime.parse(value);
      if (value.length <= 10) {
        return DateFormat('dd.MM.yyyy').format(date);
      }
      return DateFormat('dd.MM.yyyy HH:mm').format(date);
    } catch (_) {
      return value;
    }
  }

  static String _serviceTypeLabel(dynamic serviceType) {
    final value = _safe(serviceType, fallback: 'Not set');
    switch (value.toLowerCase()) {
      case 'electrician':
        return 'Electrician';
      case 'plumbing':
        return 'Plumbing';
      case 'painting':
        return 'Finishing';
      default:
        return value;
    }
  }

  static String _formatAddress(dynamic address) {
    if (address is! Map<String, dynamic>) return 'Not specified';
    final parts = <String>[];
    final city = address['city']?.toString() ?? '';
    final street = address['street']?.toString() ?? '';
    final buildingNo = address['buildingNo']?.toString() ?? '';
    final apartmentNo = address['apartmentNo']?.toString() ?? '';
    if (city.isNotEmpty) parts.add(city);
    if (street.isNotEmpty) {
      parts.add(buildingNo.isEmpty ? street : '$street, bld. $buildingNo');
    }
    if (apartmentNo.isNotEmpty) parts.add('apt. $apartmentNo');
    return parts.isEmpty ? 'Not specified' : parts.join(', ');
  }

  static String _clientLabel(Map<String, dynamic> order) {
    final fullName =
        '${order['clientSurname'] ?? ''} ${order['clientName'] ?? ''} ${order['clientPatronymic'] ?? ''}'
            .trim();
    if (fullName.isNotEmpty) return fullName;
    return _safe(order['clientUsername']);
  }

  static String _brigadierLabel(Map<String, dynamic> order) {
    if (order['brigadierId'] == null) return 'Not assigned';
    final fullName =
        '${order['brigadierSurname'] ?? ''} ${order['brigadierName'] ?? ''} ${order['brigadierPatronymic'] ?? ''}'
            .trim();
    if (fullName.isNotEmpty) return fullName;
    return _safe(order['brigadierUsername']);
  }

  static String _personLabel(Map<String, dynamic> person) {
    final surname = person['surname']?.toString() ?? '';
    final name = person['name']?.toString() ?? '';
    final patronymic = person['patronymic']?.toString() ?? '';
    final username = person['username']?.toString() ?? '';
    final fullName = '$surname $name $patronymic'.trim();
    return fullName.isEmpty
        ? (username.isEmpty ? 'Not set' : username)
        : fullName;
  }

  static String _statusLabel(String status) {
    switch (status) {
      case 'CREATED':
        return 'Created';
      case 'IN_PROGRESS':
        return 'In progress';
      case 'COMPLETED':
        return 'Completed';
      case 'APPROVED':
        return 'Approved';
      case 'REJECTED':
        return 'Rejected';
      default:
        return status;
    }
  }
}
