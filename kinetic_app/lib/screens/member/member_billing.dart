import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../services/api_client.dart';
import '../../theme/app_theme.dart';

class MemberBillingScreen extends StatefulWidget {
  @override
  _MemberBillingScreenState createState() => _MemberBillingScreenState();
}

class _MemberBillingScreenState extends State<MemberBillingScreen> {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = true;
  List<dynamic> _invoices = [];
  Map<String, dynamic>? _gymSettings;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final invRes = await _apiClient.getInvoices();
      final setRes = await _apiClient.getBillingSettings();

      if (invRes.statusCode == 200) {
        _invoices = jsonDecode(invRes.body)['results'] ?? [];
      }
      if (setRes.statusCode == 200) {
        _gymSettings = jsonDecode(setRes.body)['data'];
      }
    } catch (e) {
      print(e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showPayInvoiceDialog(String invoiceId, String amount) {
    final _receiptController = TextEditingController();
    final _transactionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF201F1F),
          title: Text('Pay Invoice (\$${amount})', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_gymSettings != null && _gymSettings!['upi_id'] != null && _gymSettings!['upi_id'].isNotEmpty) ...[
                  Text('Gym UPI ID:', style: TextStyle(color: Colors.white70)),
                  SelectableText(_gymSettings!['upi_id'], style: TextStyle(color: Colors.blueAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(height: 16),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: QrImageView(
                        data: 'upi://pay?pa=${_gymSettings!['upi_id']}&pn=Gym%20Payment&am=${amount}&cu=INR',
                        version: QrVersions.auto,
                        size: 160.0,
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Center(
                    child: Text('Scan using GPay / PhonePe / Paytm to pay \$${amount}', style: TextStyle(color: Colors.white70, fontSize: 12)),
                  ),
                  if (_gymSettings!['upi_qr_code'] != null && _gymSettings!['upi_qr_code'].toString().startsWith('http')) ...[
                    SizedBox(height: 16),
                    Text('Or use Gym Custom QR Code:', style: TextStyle(color: Colors.white70)),
                    SizedBox(height: 8),
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          _gymSettings!['upi_qr_code'],
                          height: 160,
                          width: 160,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Text('Failed to load custom QR Code Image', style: TextStyle(color: Colors.red)),
                        ),
                      ),
                    ),
                  ],
                  Divider(color: Colors.white24),
                ],
                Text('Submit Payment Receipt', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                TextField(
                  controller: _transactionController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Transaction ID',
                    labelStyle: TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: AppColors.background,
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _receiptController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Receipt Image URL / Reference',
                    labelStyle: TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: AppColors.background,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: Colors.white70))),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryFixed),
              onPressed: () async {
                final res = await _apiClient.recordPayment({
                  'invoice_id': invoiceId,
                  'amount_paid': amount,
                  'payment_method': 'UPI',
                  'transaction_id': _transactionController.text,
                  'receipt_image': _receiptController.text.isNotEmpty ? _receiptController.text : "receipt_uploaded", // stub
                });
                if (res.statusCode == 201) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Receipt submitted. Pending owner approval.')));
                  _loadData();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to submit receipt.')));
                }
              },
              child: Text('Submit Receipt', style: TextStyle(color: Colors.white)),
            )
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('My Dues & Payments', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF201F1F),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: AppColors.primaryFixed))
        : _invoices.isEmpty 
          ? Center(child: Text("No invoices found.", style: TextStyle(color: Colors.white70)))
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _invoices.length,
              itemBuilder: (context, index) {
                final inv = _invoices[index];
                final isPending = inv['status'] == 'PENDING' || inv['status'] == 'OVERDUE';
                
                return Card(
                  color: const Color(0xFF201F1F),
                  margin: EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Invoice \$${inv['total_amount']}', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isPending ? Colors.orange.withOpacity(0.2) : Colors.green.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(inv['status'], style: TextStyle(color: isPending ? Colors.orange : Colors.green, fontWeight: FontWeight.bold)),
                            )
                          ],
                        ),
                        SizedBox(height: 8),
                        Text('Due Date: ${inv['due_date']}', style: TextStyle(color: Colors.white70)),
                        if (inv['membership_name'] != null)
                          Text('Plan: ${inv['membership_name']}', style: TextStyle(color: Colors.white70)),
                        SizedBox(height: 16),
                        if (isPending)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryFixed),
                              onPressed: () => _showPayInvoiceDialog(inv['id'], inv['total_amount']),
                              child: Text('Pay Now', style: TextStyle(color: Colors.white)),
                            ),
                          )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
