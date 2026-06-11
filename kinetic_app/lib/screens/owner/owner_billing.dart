import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_client.dart';
import '../../theme/app_theme.dart';

class OwnerBillingScreen extends StatefulWidget {
  @override
  _OwnerBillingScreenState createState() => _OwnerBillingScreenState();
}

class _OwnerBillingScreenState extends State<OwnerBillingScreen> with SingleTickerProviderStateMixin {
  final ApiClient _apiClient = ApiClient();
  late TabController _tabController;

  bool _isLoading = true;
  Map<String, dynamic>? _analytics;
  List<dynamic> _invoices = [];
  List<dynamic> _payments = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final analyticsRes = await _apiClient.getBillingAnalytics();
      final invoicesRes = await _apiClient.getInvoices();
      final paymentsRes = await _apiClient.getPayments();

      if (analyticsRes.statusCode == 200) {
        _analytics = jsonDecode(analyticsRes.body)['data'];
      }
      if (invoicesRes.statusCode == 200) {
        _invoices = jsonDecode(invoicesRes.body)['results'] ?? [];
      }
      if (paymentsRes.statusCode == 200) {
        _payments = jsonDecode(paymentsRes.body)['results'] ?? [];
      }
    } catch (e) {
      print("Error loading billing data: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _acknowledgePayment(String id, String action) async {
    try {
      final res = await _apiClient.acknowledgePayment(id, {'action': action});
      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment $action successfully.')));
        _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to $action.')));
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Billing & Payments', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF201F1F),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            tooltip: 'Payment Settings',
            onPressed: () => context.push('/owner/billing/settings').then((_) => _loadData()),
          )
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryFixed,
          unselectedLabelColor: Colors.white70,
          indicatorColor: AppColors.primaryFixed,
          tabs: [
            Tab(text: 'Analytics'),
            Tab(text: 'Invoices'),
            Tab(text: 'Receipts/Payments'),
          ],
        ),
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: AppColors.primaryFixed))
        : TabBarView(
            controller: _tabController,
            children: [
              _buildAnalyticsTab(),
              _buildInvoicesTab(),
              _buildPaymentsTab(),
            ],
          ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateInvoiceDialog,
        backgroundColor: AppColors.primaryFixed,
        icon: Icon(Icons.add),
        label: Text('Invoice'),
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    if (_analytics == null) return Center(child: Text("Failed to load analytics", style: TextStyle(color: Colors.white)));
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildStatCard('Total Revenue', '\$${_analytics!['total_revenue']}', Icons.monetization_on, Colors.green),
          SizedBox(height: 16),
          _buildStatCard('This Month', '\$${_analytics!['monthly_revenue']}', Icons.calendar_today, Colors.blue),
          SizedBox(height: 16),
          _buildStatCard('Pending Dues', '\$${_analytics!['pending_dues']}', Icons.warning_amber_rounded, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF201F1F),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, color: color, size: 30),
          ),
          SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(color: Colors.white70, fontSize: 16)),
              SizedBox(height: 8),
              Text(value, style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildInvoicesTab() {
    if (_invoices.isEmpty) return Center(child: Text("No invoices found.", style: TextStyle(color: Colors.white70)));
    
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _invoices.length,
      itemBuilder: (context, index) {
        final inv = _invoices[index];
        final statusColor = inv['status'] == 'PAID' ? Colors.green : (inv['status'] == 'OVERDUE' ? Colors.red : Colors.orange);
        
        return Card(
          color: const Color(0xFF201F1F),
          margin: EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            title: Text('${inv['member_name']} - \$${inv['total_amount']}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Text('Due: ${inv['due_date']} | Status: ${inv['status']}', style: TextStyle(color: Colors.white70)),
            trailing: Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
            onTap: () => _showRecordPaymentDialog(inv['id']),
          ),
        );
      },
    );
  }

  Widget _buildPaymentsTab() {
    if (_payments.isEmpty) return Center(child: Text("No payments found.", style: TextStyle(color: Colors.white70)));
    
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _payments.length,
      itemBuilder: (context, index) {
        final pay = _payments[index];
        return Card(
          color: const Color(0xFF201F1F),
          margin: EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ExpansionTile(
            title: Text('${pay['member_name']} - \$${pay['amount_paid']}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Text('Method: ${pay['payment_method']} | Status: ${pay['status']}', style: TextStyle(color: Colors.white70)),
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (pay['receipt_image'] != null && pay['receipt_image'].isNotEmpty)
                      Text("Receipt Provided", style: TextStyle(color: Colors.blueAccent)),
                    SizedBox(height: 10),
                    if (pay['status'] == 'PENDING_ACK')
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            onPressed: () => _acknowledgePayment(pay['id'], 'ACKNOWLEDGE'),
                            child: Text('Acknowledge', style: TextStyle(color: Colors.white)),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            onPressed: () => _acknowledgePayment(pay['id'], 'REJECT'),
                            child: Text('Reject', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      )
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void _showCreateInvoiceDialog() {
    // Basic dialog to create invoice (requires member list).
    // For simplicity in this step, we can navigate to a new screen or show a placeholder message
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Use the API/Postman or upcoming Member selection UI to create invoices.')));
  }
  
  void _showRecordPaymentDialog(String invoiceId) {
    // Show dialog to record a manual payment for this invoice
    showDialog(
      context: context,
      builder: (context) {
        final amountController = TextEditingController();
        String method = 'CASH';
        return AlertDialog(
          backgroundColor: const Color(0xFF201F1F),
          title: Text('Record Payment', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Amount Paid',
                  labelStyle: TextStyle(color: Colors.white70),
                ),
              ),
              DropdownButton<String>(
                value: method,
                dropdownColor: const Color(0xFF201F1F),
                items: ['CASH', 'CARD', 'UPI', 'BANK_TRANSFER'].map((e) => DropdownMenuItem(value: e, child: Text(e, style: TextStyle(color: Colors.white)))).toList(),
                onChanged: (val) { if(val!=null) method = val; },
              )
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: Colors.white70))),
            ElevatedButton(
              onPressed: () async {
                if (amountController.text.isNotEmpty) {
                  await _apiClient.recordPayment({
                    'invoice_id': invoiceId,
                    'amount_paid': amountController.text,
                    'payment_method': method
                  });
                  Navigator.pop(context);
                  _loadData();
                }
              },
              child: Text('Submit'),
            )
          ],
        );
      }
    );
  }
}
