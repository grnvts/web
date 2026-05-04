import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

Color orderStatusColor(String? status) {
  switch (status) {
    case 'CREATED':
      return Colors.blue;
    case 'IN_PROGRESS':
      return Colors.orange;
    case 'COMPLETED':
      return Colors.green;
    case 'APPROVED':
      return Colors.teal;
    case 'REJECTED':
      return Colors.red;
    default:
      return Colors.grey;
  }
}

String orderStatusLabel(String? status) {
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
      return status ?? 'Unknown';
  }
}

String orderServiceTypeLabel(String? serviceType) {
  if (serviceType == null || serviceType.isEmpty) {
    return 'Not set';
  }

  switch (serviceType.toLowerCase()) {
    case 'electrician':
      return 'Electrician';
    case 'plumbing':
      return 'Plumbing';
    case 'painting':
      return 'Finishing';
    default:
      return serviceType;
  }
}

String formatOrderDate(
  String? value, {
  String emptyLabel = 'Not set',
  bool includeTime = true,
}) {
  if (value == null || value.isEmpty) {
    return emptyLabel;
  }

  try {
    final date = DateTime.parse(value);
    if (!includeTime || value.length <= 10) {
      return DateFormat('dd.MM.yyyy').format(date);
    }
    return DateFormat('dd.MM.yyyy HH:mm').format(date);
  } catch (_) {
    return value;
  }
}

String formatOrderAddress(
  dynamic address, {
  String emptyLabel = 'Address not set',
}) {
  if (address is! Map) {
    return emptyLabel;
  }

  final parts = <String>[];
  final city = address['city']?.toString() ?? '';
  final street = address['street']?.toString() ?? '';
  final buildingNo = address['buildingNo']?.toString() ?? '';
  final apartmentNo = address['apartmentNo']?.toString() ?? '';

  if (city.isNotEmpty) {
    parts.add(city);
  }
  if (street.isNotEmpty) {
    parts.add(buildingNo.isEmpty ? street : '$street, bld. $buildingNo');
  }
  if (apartmentNo.isNotEmpty) {
    parts.add('apt. $apartmentNo');
  }

  return parts.isEmpty ? emptyLabel : parts.join(', ');
}
