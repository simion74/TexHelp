import 'package:flutter/material.dart';
import '../services/export_service.dart';
import '../theme/app_colors.dart';
import '../widgets/ai_icon.dart';
import '../widgets/sheet_field.dart';

/// 📋 Order Sheet — Buyer/Style/Color তথ্য ও সাইজ-ভিত্তিক কোয়ান্টিটি
/// ব্রেকডাউন ফিল-আপ করে সরাসরি Excel/PDF/Image এক্সপোর্ট করা যায়।
class OrderSheetScreen extends StatefulWidget {
  const OrderSheetScreen({super.key});

  @override
  State<OrderSheetScreen> createState() => _OrderSheetScreenState();
}

class _OrderSheetScreenState extends State<OrderSheetScreen> {
  final _buyer = TextEditingController();
  final _styleNo = TextEditingController();
  final _poNo = TextEditingController();
  final _color = TextEditingController();
  final _unitPrice = TextEditingController();

  static const List<String> _sizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];
  final Map<String, TextEditingController> _sizeQty = {
    for (final s in _sizes) s: TextEditingController(),
  };

  final GlobalKey _summaryKey = GlobalKey();

  double _d(TextEditingController c) => double.tryParse(c.text.trim()) ?? 0;

  int get _totalQty =>
      _sizes.fold(0, (sum, s) => sum + (int.tryParse(_sizeQty[s]!.text) ?? 0));

  double get _totalValue => _totalQty * _d(_unitPrice);

  @override
  void dispose() {
    _buyer.dispose();
    _styleNo.dispose();
    _poNo.dispose();
    _color.dispose();
    _unitPrice.dispose();
    for (final c in _sizeQty.values) {
      c.dispose();
    }
    super.dispose();
  }

  List<String> get _headers => ['Size', 'Quantity'];

  List<List<String>> get _rows => [
        ..._sizes.map((s) => [s, _sizeQty[s]!.text.isEmpty ? '0' : _sizeQty[s]!.text]),
        ['TOTAL', _totalQty.toString()],
      ];

  List<String> get _infoHeaders => ['Item', 'Value'];
  List<List<String>> get _infoRows => [
        ['Buyer', _buyer.text],
        ['Style No', _styleNo.text],
        ['PO No', _poNo.text],
        ['Color', _color.text],
        ['Unit Price', _unitPrice.text],
        ['Total Quantity', _totalQty.toString()],
        ['Total Value', _totalValue.toStringAsFixed(2)],
      ];

  Future<void> _exportExcel() async {
    await ExportService.exportExcel(
      fileName: 'Order_Sheet_${_poNo.text.isEmpty ? 'Draft' : _poNo.text}',
      sheetTitle: 'Order Sheet',
      headers: _infoHeaders,
      rows: [
        ..._infoRows,
        <String>[''],
        _headers,
        ..._rows,
      ],
    );
  }

  Future<void> _exportPdf() async {
    await ExportService.exportPdf(
      fileName: 'Order_Sheet_${_poNo.text.isEmpty ? 'Draft' : _poNo.text}',
      title: 'Order Sheet',
      headers: _headers,
      rows: _rows,
    );
  }

  Future<void> _exportImage() async {
    await ExportService.exportImage(
      repaintKey: _summaryKey,
      fileName: 'Order_Sheet_${_poNo.text.isEmpty ? 'Draft' : _poNo.text}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F5F4),
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                    14, statusBarHeight > 0 ? 2 : 10, 14, 10),
                child: Row(
                  children: [
                    Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      elevation: 3,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => Navigator.of(context).pop(),
                        child: const Padding(
                          padding: EdgeInsets.all(9),
                          child: Icon(Icons.arrow_back_rounded,
                              color: AppColors.darkGreen, size: 18),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Image.asset(
                      'assets/homeicon/order_sheet.webp',
                      width: 22,
                      height: 22,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Order Sheet',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkGreen),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('অর্ডার তথ্য'),
                      Row(
                        children: [
                          Expanded(
                            child: SheetField(
                                label: 'Buyer',
                                controller: _buyer,
                                onChanged: (_) => setState(() {})),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SheetField(
                                label: 'Style No',
                                controller: _styleNo,
                                onChanged: (_) => setState(() {})),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: SheetField(
                                label: 'PO No',
                                controller: _poNo,
                                onChanged: (_) => setState(() {})),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: SheetField(
                                label: 'Color',
                                controller: _color,
                                onChanged: (_) => setState(() {})),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SheetField(
                        label: 'Unit Price (ঐচ্ছিক)',
                        controller: _unitPrice,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 18),
                      _sectionTitle('সাইজ-ভিত্তিক কোয়ান্টিটি'),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _sizes.map((s) {
                          return SizedBox(
                            width:
                                (MediaQuery.of(context).size.width - 28 - 20) /
                                    3,
                            child: SheetField(
                              label: s,
                              controller: _sizeQty[s]!,
                              keyboardType: TextInputType.number,
                              onChanged: (_) => setState(() {}),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      RepaintBoundary(
                        key: _summaryKey,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3)),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  AiIcon(size: 16),
                                  SizedBox(width: 6),
                                  Text('TexHelp — Order Summary',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.darkGreen)),
                                ],
                              ),
                              const Divider(height: 18),
                              if (_buyer.text.isNotEmpty)
                                _summaryRow('Buyer', _buyer.text),
                              if (_styleNo.text.isNotEmpty)
                                _summaryRow('Style No', _styleNo.text),
                              if (_color.text.isNotEmpty)
                                _summaryRow('Color', _color.text),
                              const Divider(height: 18),
                              ..._sizes
                                  .where((s) => _sizeQty[s]!.text.isNotEmpty)
                                  .map((s) => _summaryRow(
                                      s, _sizeQty[s]!.text)),
                              const Divider(height: 18),
                              _summaryRow(
                                  'Total Quantity', '$_totalQty pcs',
                                  bold: true),
                              if (_d(_unitPrice) > 0)
                                _summaryRow('Total Value',
                                    _totalValue.toStringAsFixed(2),
                                    bold: true),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ExportButtonRow(
                        onExcel: _exportExcel,
                        onPdf: _exportPdf,
                        onImage: _exportImage,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: AppColors.green),
        ),
      );

  Widget _summaryRow(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: bold ? 13 : 12,
                  fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
                  color: bold ? AppColors.darkGreen : Colors.black54)),
          Text(value,
              style: TextStyle(
                  fontSize: bold ? 13 : 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkGreen)),
        ],
      ),
    );
  }
}
