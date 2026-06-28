import 'dart:convert';
import 'package:flutter/model.dart'; // Wait! Flutter doesn't have package:flutter/model.dart. That's a typo in thought. Let's import flutter/material.dart.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_theme.dart';
import '../../../services/api_client.dart';

class SaasBillingScreen extends StatefulWidget {
  const SaasBillingScreen({super.key});

  @override
  State<SaasBillingScreen> createState() => _SaasBillingScreenState();
}

class _SaasBillingScreenState extends State<SaasBillingScreen> {
  final ApiClient _apiClient = ApiClient();
  bool _isLoading = true;
  String _errorMessage = '';

  List<dynamic> _invoices = [];
  List<dynamic> _history = [];
  bool _isPaying = false;

  @override
  void initState() {
    super.initState();
    _fetchBillingDetails();
  }

  Future<void> _fetchBillingDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final res = await _apiClient.getSaaSInvoices();
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body['success'] == true) {
          setState(() {
            _invoices = body['data']['invoices'] ?? [];
            _history = body['data']['history'] ?? [];
          });
        } else {
          setState(() => _errorMessage = body['message'] ?? 'Failed to load billing history');
        }
      } else {
        setState(() => _errorMessage = 'Failed to load details. Code: ${res.statusCode}');
      }
    } catch (e) {
      setState(() => _errorMessage = 'Network error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _payInvoice(String invoiceId) async {
    setState(() => _isPaying = true);
    try {
      final res = await _apiClient.paySaaSInvoice(invoiceId);
      final body = jsonDecode(res.body);
      if (res.statusCode == 200 && body['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Payment checkout simulated successfully! Plan updated.'), backgroundColor: Colors.green),
          );
        }
        _fetchBillingDetails();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(body['message'] ?? 'Payment failed'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isPaying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'BILLING & INVOICES',
          style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryFixed))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_errorMessage.isNotEmpty) ...[
                      Text(_errorMessage, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                    ],
                    const Text('PENDING INVOICES', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 12),
                    if (_invoices.where((inv) => inv['status'] != 'PAID').isEmpty)
                      _buildEmptyCard('No pending invoices found.')
                    else
                      ..._invoices.where((inv) => inv['status'] != 'PAID').map((inv) => _buildInvoiceCard(inv)),
                    const SizedBox(height: 28),
                    const Text('TRANSACTION HISTORY', style: TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 12),
                    if (_history.isEmpty && _invoices.where((inv) => inv['status'] == 'PAID').isEmpty)
                      _buildEmptyCard('No transactions found.')
                    else ...[
                      ..._invoices.where((inv) => inv['status'] == 'PAID').map((inv) => _buildPaidInvoiceCard(inv)),
                      ..._history.map((tx) => _buildTransactionCard(tx)),
                    ],
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildEmptyCard(String msg) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF201F1F),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(msg, style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 13)),
    );
  }

  Widget _buildInvoiceCard(Map<String, dynamic> inv) {
    final invoiceId = inv['id'];
    final number = inv['invoice_number'];
    final amount = inv['amount'];
    final tax = inv['tax'];
    final statusVal = inv['status'];
    final due = inv['due_date'];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF201F1F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.redAccent.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(number, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 15)),
              Text('₹$amount', style: const TextStyle(color: AppColors.primaryFixed, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tax (18% GST included): ₹$tax', style: const TextStyle(color: Colors.white30, fontSize: 12)),
              Text('Due: $due', style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _isPaying ? null : () => _payInvoice(invoiceId),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryFixed,
              foregroundColor: AppColors.background,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: _isPaying
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.background))
                : const Text('SIMULATE CARD PAYMENT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          )
        ],
      ),
    );
  }

  Widget _buildPaidInvoiceCard(Map<String, dynamic> inv) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF201F1F),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(inv['invoice_number'], style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 4),
              const Text('Invoice Paid', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          Text('₹${inv['amount']}', style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold, fontSize: 15)),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> tx) {
    final amount = tx['amount'];
    final method = tx['payment_method'];
    final date = tx['created_at'].toString().split('T')[0];
    final ref = tx['transaction_reference'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF201F1F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.white.withOpacity(0.02)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(method, style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.w500, fontSize: 13)),
              const SizedBox(height: 4),
              Text('Tx: $ref', style: const TextStyle(color: Colors.white30, fontSize: 11)),
              const SizedBox(height: 2),
              Text(date, style: const TextStyle(color: Colors.white24, fontSize: 10)),
            ],
          ),
          Text('+₹$amount', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }
}
