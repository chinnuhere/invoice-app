import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class PdfService {
  static Future<void> generateAndShareInvoice(Map<String, dynamic> invoice) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'INVOICE',
                        style: pw.TextStyle(
                          fontSize: 32,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        invoice['invoice_number']?.toString() ?? 'INV-000',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Status: ${(invoice['status']?.toString() ?? 'DRAFT').toUpperCase()}',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: _getStatusColor(invoice['status']?.toString() ?? 'draft'),
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'Date: ${invoice['issue_date']?.toString() ?? 'N/A'}',
                        style: pw.TextStyle(fontSize: 12),
                      ),
                      pw.Text(
                        'Due: ${invoice['due_date']?.toString() ?? 'N/A'}',
                        style: pw.TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 32),

              // Bill To Section
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'BILL TO',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      invoice['client_name']?.toString() ?? 'Unknown Client',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    if (invoice['client_email'] != null && invoice['client_email'].toString().isNotEmpty)
                      pw.Text(
                        invoice['client_email']?.toString() ?? '',
                        style: pw.TextStyle(fontSize: 12),
                      ),
                    if (invoice['client_phone'] != null && invoice['client_phone'].toString().isNotEmpty)
                      pw.Text(
                        invoice['client_phone']?.toString() ?? '',
                        style: pw.TextStyle(fontSize: 12),
                      ),
                    if (invoice['client_company'] != null && invoice['client_company'].toString().isNotEmpty)
                      pw.Text(
                        invoice['client_company']?.toString() ?? '',
                        style: pw.TextStyle(fontSize: 12),
                      ),
                    if (invoice['client_address'] != null && invoice['client_address'].toString().isNotEmpty)
                      pw.Text(
                        invoice['client_address']?.toString() ?? '',
                        style: pw.TextStyle(fontSize: 12),
                      ),
                  ],
                ),
              ),
              pw.SizedBox(height: 32),

              // Items Table
              pw.Text(
                'ITEMS',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 16),
              _buildItemsTable(invoice['items'] as List<dynamic>? ?? []),
              pw.SizedBox(height: 32),

              // Totals
              _buildTotalsSection(invoice),

              // Notes
              if (invoice['notes'] != null && invoice['notes'].toString().isNotEmpty) ...[
                pw.SizedBox(height: 32),
                pw.Text(
                  'NOTES',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  invoice['notes']?.toString() ?? '',
                  style: pw.TextStyle(fontSize: 12),
                ),
              ],
            ],
          );
        },
      ),
    );

    // Share the PDF
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'invoice_${invoice['invoice_number']}.pdf',
    );
  }

  static Future<void> downloadInvoice(Map<String, dynamic> invoice) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'INVOICE',
                        style: pw.TextStyle(
                          fontSize: 32,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        invoice['invoice_number']?.toString() ?? 'INV-000',
                        style: pw.TextStyle(
                          fontSize: 18,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Status: ${(invoice['status']?.toString() ?? 'DRAFT').toUpperCase()}',
                        style: pw.TextStyle(
                          fontSize: 14,
                          fontWeight: pw.FontWeight.bold,
                          color: _getStatusColor(invoice['status']?.toString() ?? 'draft'),
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        'Date: ${invoice['issue_date']?.toString() ?? 'N/A'}',
                        style: pw.TextStyle(fontSize: 12),
                      ),
                      pw.Text(
                        'Due: ${invoice['due_date']?.toString() ?? 'N/A'}',
                        style: pw.TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 32),

              // Bill To Section
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'BILL TO',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey700,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      invoice['client_name']?.toString() ?? 'Unknown Client',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    if (invoice['client_email'] != null && invoice['client_email'].toString().isNotEmpty)
                      pw.Text(
                        invoice['client_email']?.toString() ?? '',
                        style: pw.TextStyle(fontSize: 12),
                      ),
                    if (invoice['client_phone'] != null && invoice['client_phone'].toString().isNotEmpty)
                      pw.Text(
                        invoice['client_phone']?.toString() ?? '',
                        style: pw.TextStyle(fontSize: 12),
                      ),
                    if (invoice['client_company'] != null && invoice['client_company'].toString().isNotEmpty)
                      pw.Text(
                        invoice['client_company']?.toString() ?? '',
                        style: pw.TextStyle(fontSize: 12),
                      ),
                    if (invoice['client_address'] != null && invoice['client_address'].toString().isNotEmpty)
                      pw.Text(
                        invoice['client_address']?.toString() ?? '',
                        style: pw.TextStyle(fontSize: 12),
                      ),
                  ],
                ),
              ),
              pw.SizedBox(height: 32),

              // Items Table
              pw.Text(
                'ITEMS',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 16),
              _buildItemsTable(invoice['items'] as List<dynamic>? ?? []),
              pw.SizedBox(height: 32),

              // Totals
              _buildTotalsSection(invoice),

              // Notes
              if (invoice['notes'] != null && invoice['notes'].toString().isNotEmpty) ...[
                pw.SizedBox(height: 32),
                pw.Text(
                  'NOTES',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  invoice['notes']?.toString() ?? '',
                  style: pw.TextStyle(fontSize: 12),
                ),
              ],
            ],
          );
        },
      ),
    );

    // Download the PDF
    if (kIsWeb) {
      // For web, use share functionality
      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'invoice_${invoice['invoice_number']}.pdf',
      );
    } else {
      // For mobile/desktop, save to device
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/invoice_${invoice['invoice_number']}.pdf');
      await file.writeAsBytes(await pdf.save());
    }
  }

  static pw.Widget _buildItemsTable(List<dynamic> items) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(1),
        3: const pw.FlexColumnWidth(1),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: pw.BoxDecoration(color: PdfColors.blue100),
          children: [
            _buildTableCell('Description', isHeader: true),
            _buildTableCell('Qty', isHeader: true),
            _buildTableCell('Price', isHeader: true),
            _buildTableCell('Total', isHeader: true),
          ],
        ),
        // Items
        ...items.asMap().entries.map((entry) {
          final item = entry.value;
          final quantity = (item['quantity'] as num?)?.toDouble() ?? 0;
          final unitPrice = (item['unit_price'] as num?)?.toDouble() ?? 0;
          final total = quantity * unitPrice;
          return pw.TableRow(
            children: [
              _buildTableCell(item['description']?.toString() ?? ''),
              _buildTableCell(quantity.toString()),
              _buildTableCell('\$${unitPrice.toStringAsFixed(2)}'),
              _buildTableCell('\$${total.toStringAsFixed(2)}'),
            ],
          );
        }).toList(),
      ],
    );
  }

  static pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 12 : 11,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  static pw.Widget _buildTotalsSection(Map<String, dynamic> invoice) {
    final subtotal = (invoice['subtotal'] as num?)?.toDouble() ?? 0;
    final tax = (invoice['tax'] as num?)?.toDouble() ?? 0;
    final total = (invoice['total'] as num?)?.toDouble() ?? 0;

    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      child: pw.Column(
        children: [
          _buildTotalRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
          pw.SizedBox(height: 8),
          _buildTotalRow('Tax', '\$${tax.toStringAsFixed(2)}'),
          pw.Divider(),
          pw.SizedBox(height: 8),
          _buildTotalRow(
            'Total',
            '\$${total.toStringAsFixed(2)}',
            isBold: true,
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildTotalRow(String label, String value, {bool isBold = false}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
          ),
        ),
      ],
    );
  }

  static PdfColor _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return PdfColors.grey600;
      case 'sent':
        return PdfColors.blue700;
      case 'paid':
        return PdfColors.green700;
      case 'overdue':
        return PdfColors.red700;
      default:
        return PdfColors.grey600;
    }
  }
}
