import 'dart:convert';
import 'package:flutter/material.dart';
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
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('Payment Settings', style: TextStyle(color: Colors.white)),
        backgroundColor: AppTheme.cardColor,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _isLoading 
        ? Center(child: CircularProgressIndicator(color: AppTheme.primary))
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    fillColor: AppTheme.cardColor,
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
                    fillColor: AppTheme.cardColor,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _isSaving ? null : _saveSettings,
                  child: _isSaving ? CircularProgressIndicator(color: Colors.white) : Text('Save Settings', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                )
              ],
            ),
          ),
    );
  }
}
