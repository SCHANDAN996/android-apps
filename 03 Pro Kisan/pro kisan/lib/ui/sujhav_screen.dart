import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/server_config.dart';
import '../l10n/app_localizations.dart';
// ignore_for_file: deprecated_member_use

/// ---------------------------------------------------------------------------
///  सुझाव / शिकायत — Server-Powered Feedback + Admin Notices
/// ---------------------------------------------------------------------------
class SujhavScreen extends StatefulWidget {
  const SujhavScreen({super.key});

  @override
  State<SujhavScreen> createState() => _SujhavScreenState();
}

class _SujhavScreenState extends State<SujhavScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Form
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  String _category = 'सुझाव';
  bool _sending = false;

  // Notices
  List<Map<String, dynamic>> _notices = [];
  bool _loadingNotices = true;
  String? _noticeError;

  // Category values stay in Hindi (sent to the server / read by admin);
  // only their display label is localized.
  static const _categories = ['सुझाव', 'शिकायत', 'प्रश्न'];

  String _t(String k) => AppLocalizations.get(context, k);

  String _catLabel(String c) {
    switch (c) {
      case 'शिकायत':
        return _t('catComplaint');
      case 'प्रश्न':
        return _t('catQuestion');
      default:
        return _t('catSuggestion');
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchNotices();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  // ── Fetch Notices from Server ──────────────────────────────────────────
  Future<void> _fetchNotices() async {
    setState(() { _loadingNotices = true; _noticeError = null; });
    try {
      final response = await http.get(Uri.parse(ServerConfig.noticesUrl))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        setState(() {
          _notices = data.cast<Map<String, dynamic>>();
          _loadingNotices = false;
        });
      } else {
        setState(() { _noticeError = '${_t('sujhavServerErr')} (${response.statusCode})'; _loadingNotices = false; });
      }
    } catch (e) {
      setState(() { _noticeError = _t('sujhavNoConnect'); _loadingNotices = false; });
    }
  }

  // ── Submit Sujhav to Server ────────────────────────────────────────────
  Future<void> _submitSujhav() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _sending = true);
    try {
      final response = await http.post(
        Uri.parse(ServerConfig.sujhavUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'farmer_name': _nameCtrl.text.trim(),
          'phone': _phoneCtrl.text.trim(),
          'category': _category,
          'message': _messageCtrl.text.trim(),
        }),
      ).timeout(const Duration(seconds: 15));

      setState(() => _sending = false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _nameCtrl.clear();
        _phoneCtrl.clear();
        _messageCtrl.clear();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_t('sujhavSuccess'), style: const TextStyle(fontWeight: FontWeight.bold)),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        _showError(_t('sujhavServerErr'));
      }
    } catch (e) {
      setState(() => _sending = false);
      _showError(_t('sujhavNoConnect'));
    }
  }

  void _showError(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_t('sujhavTitle')),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: [
            Tab(icon: const Icon(Icons.edit_note_rounded), text: _t('sujhavTabSend')),
            Tab(icon: const Icon(Icons.campaign_rounded), text: _t('sujhavTabNotices')),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildSujhavForm(),
          _buildNoticesList(),
        ],
      ),
      ),
    );
  }

  // ── Tab 1: Suggestion Form ─────────────────────────────────────────────
  Widget _buildSujhavForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple.shade50, Colors.purple.shade50],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.deepPurple.shade100),
              ),
              child: Column(
                children: [
                  Icon(Icons.feedback_rounded, size: 40, color: Colors.deepPurple.shade400),
                  const SizedBox(height: 8),
                  Text(_t('sujhavHeaderMsg'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                  const SizedBox(height: 4),
                  Text(_t('sujhavHeaderHint'),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Name
            TextFormField(
              controller: _nameCtrl,
              decoration: InputDecoration(
                labelText: _t('sujhavName'),
                hintText: _t('sujhavNameHint'),
                prefixIcon: const Icon(Icons.person_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? _t('sujhavNameErr') : null,
            ),
            const SizedBox(height: 14),

            // Phone
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              decoration: InputDecoration(
                labelText: _t('sujhavPhone'),
                hintText: '9876543210',
                prefixIcon: const Icon(Icons.phone_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade50,
                counterText: '',
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return _t('sujhavPhoneErr');
                if (v.trim().length < 10) return _t('sujhavPhoneErr2');
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Category
            DropdownButtonFormField<String>(
              value: _category,
              decoration: InputDecoration(
                labelText: _t('sujhavCategory'),
                prefixIcon: const Icon(Icons.category_rounded),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(_catLabel(c)))).toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 14),

            // Message
            TextFormField(
              controller: _messageCtrl,
              maxLines: 5,
              maxLength: 500,
              decoration: InputDecoration(
                labelText: _t('sujhavMsg'),
                hintText: _t('sujhavMsgHint'),
                alignLabelWithHint: true,
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 80),
                  child: Icon(Icons.message_rounded),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? _t('sujhavMsgErr') : null,
            ),
            const SizedBox(height: 20),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _sending ? null : _submitSujhav,
                icon: _sending
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send_rounded),
                label: Text(_sending ? _t('sujhavSending') : _t('sujhavTabSend'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ── Tab 2: Server Notices ──────────────────────────────────────────────
  Widget _buildNoticesList() {
    if (_loadingNotices) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_noticeError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_rounded, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(_noticeError!, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _fetchNotices,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(_t('tryAgain')),
            ),
          ],
        ),
      );
    }
    if (_notices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none_rounded, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(_t('noticeNone'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(_t('noticeNoneHint'), style: TextStyle(color: Colors.grey.shade500)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchNotices,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _notices.length,
        itemBuilder: (context, index) {
          final n = _notices[index];
          return _buildNoticeCard(n);
        },
      ),
    );
  }

  Widget _buildNoticeCard(Map<String, dynamic> notice) {
    final type = notice['type'] ?? 'info';
    Color color;
    IconData icon;
    String badge;
    final isHi = AppLocalizations.isHindiLike(context);

    switch (type) {
      case 'alert':
        color = Colors.red;
        icon = Icons.warning_amber_rounded;
        badge = isHi ? '⚠️ अलर्ट' : '⚠️ Alert';
        break;
      case 'update':
        color = Colors.green;
        icon = Icons.system_update_rounded;
        badge = isHi ? '🆕 अपडेट' : '🆕 Update';
        break;
      default:
        color = Colors.blue;
        icon = Icons.info_rounded;
        badge = isHi ? 'ℹ️ सूचना' : 'ℹ️ Info';
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border(left: BorderSide(color: color, width: 4)),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(badge, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
                ),
                const Spacer(),
                Text(
                  notice['created_at'] ?? '',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              notice['title'] ?? '',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              notice['body'] ?? '',
              style: TextStyle(fontSize: 13, height: 1.4, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }
}
