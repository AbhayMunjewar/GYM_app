import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../services/api_client.dart';
import '../../theme/app_theme.dart';

class OwnerBillingSettingsScreen extends StatefulWidget {
  @override
  _OwnerBillingSettingsScreenState createState() => _OwnerBillingSettingsScreenState();
}

class _OwnerBillingSettingsScreenState extends State<OwnerBillingSettingsScreen> {
  final ApiClient _apiClient = ApiClient();
  final _upiIdController = TextEditingController();
  final _upiQrController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _upiIdController.addListener(_onUpiChanged);
  }

  @override
  void dispose() {
    _upiIdController.removeListener(_onUpiChanged);
    _upiIdController.dispose();
    _upiQrController.dispose();
    super.dispose();
  }

  void _onUpiChanged() {
    setState(() {});
  }

  Future<void> _loadSettings() async {
    try {
      final res = await _apiClient.getBillingSettings();
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body)['data'];
        if (data != null) {
          _upiIdController.text = data['upi_id'] ?? '';
          _upiQrController.text = data['upi_qr_code'] ?? '';
        }
      }
    } catch (e) {
      print(e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    try {
      final res = await _apiClient.updateBillingSettings({
        'upi_id': _upiIdController.text,
        'upi_qr_code': _upiQrController.text,
      });
      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Settings saved successfully')));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save settings')));
      }
    } catch (e) {
      print(e);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Payment Settings', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF201F1F),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: AppColors.primaryFixed))
        : ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Text("Configure your Gym's Payment details so members can pay via UPI.", style: TextStyle(color: Colors.white70)),
              SizedBox(height: 20),
              TextField(
                controller: _upiIdController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Gym UPI ID (e.g., gym@okhdfc)',
                  labelStyle: TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: const Color(0xFF201F1F),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _upiQrController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'UPI QR Code URL (Optional)',
                  labelStyle: TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: const Color(0xFF201F1F),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              if (_upiIdController.text.isNotEmpty) ...[
                SizedBox(height: 24),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: QrImageView(
                      data: 'upi://pay?pa=${_upiIdController.text}&pn=Gym%20Payment',
                      version: QrVersions.auto,
                      size: 160.0,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Center(
                  child: Text(
                    'Preview of Generated UPI QR Code',
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ),
              ],
              SizedBox(height: 30),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryFixed,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _isSaving ? null : _saveSettings,
                child: _isSaving ? SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : Text('Save Settings', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
              )
            ],
          ),
    );
  }
}
