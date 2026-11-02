import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:nischint_core/app/app_scope.dart';
import 'package:nischint_core/app/app_state.dart';
import 'package:nischint_core/app/theme.dart';
import 'package:nischint_core/content/catalog.dart';
import 'package:nischint_core/models/complaint.dart';
import 'package:nischint_core/services/contact_service.dart';
import 'package:nischint_core/utils/format.dart';
import 'package:nischint_core/widgets/common.dart';
import 'package:nischint_core/widgets/pickers.dart';
import 'widgets/complaint_bits.dart';

/// वेंडर अपने ग्राहक की नई शिकायत दर्ज करता है और WhatsApp पर हमें भेजता है।
class ComplaintFormScreen extends StatefulWidget {
  const ComplaintFormScreen({super.key});

  @override
  State<ComplaintFormScreen> createState() => _ComplaintFormScreenState();
}

class _ComplaintFormScreenState extends State<ComplaintFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _addressController = TextEditingController();
  final _portalIdController = TextEditingController();
  final _noteController = TextEditingController();

  String _area = '';
  int _kw = 3;
  String _problem = '';
  DateTime _complaintDate = _today();
  bool _urgent = false;

  String? _areaError;
  String? _problemError;
  bool _triedSubmit = false;
  bool _sending = false;

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    _addressController.dispose();
    _portalIdController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String? _required(String? value, String message) {
    if ((value ?? '').trim().isEmpty) return message;
    return null;
  }

  String? _validateMobile(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'ग्राहक का मोबाइल नंबर लिखें';
    if (v.length != 10 || !isValidMobile(v)) return 'सही 10 अंक का मोबाइल नंबर लिखें';
    return null;
  }

  Future<void> _pickDate() async {
    FocusScope.of(context).unfocus();
    final today = _today();
    final first = DateTime(today.year, today.month, today.day - 60);
    var initial = _complaintDate;
    if (initial.isAfter(today)) initial = today;
    if (initial.isBefore(first)) initial = first;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: today,
      helpText: 'ग्राहक ने शिकायत कब की?',
      cancelText: 'रद्द करें',
      confirmText: 'ठीक है',
    );
    if (!mounted || picked == null) return;
    setState(() => _complaintDate = DateTime(picked.year, picked.month, picked.day));
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    final formOk = _formKey.currentState?.validate() ?? false;
    // खानों की सीधी जाँच भी, ताकि कोई ज़रूरी जानकारी छूटे नहीं।
    final fieldsOk = formOk &&
        _nameController.text.trim().isNotEmpty &&
        _validateMobile(_mobileController.text) == null &&
        _addressController.text.trim().isNotEmpty;
    setState(() {
      _triedSubmit = true;
      _areaError = _area.isEmpty ? 'इलाका चुनें' : null;
      _problemError = _problem.isEmpty ? 'दिक्कत चुनें' : null;
    });
    if (!fieldsOk || _areaError != null || _problemError != null) {
      showMessage(context, 'कृपया लाल निशान वाली जानकारी पूरी करें');
      return;
    }

    setState(() => _sending = true);
    final app = AppScope.read(context);
    final complaint = VendorComplaint(
      id: AppState.newComplaintId(),
      customerName: _nameController.text.trim(),
      customerMobile: _mobileController.text.trim(),
      address: _addressController.text.trim(),
      area: _area,
      systemKw: _kw,
      problem: _problem,
      complaintDate: _complaintDate,
      createdAt: DateTime.now(),
      portalComplaintId: _portalIdController.text.trim(),
      urgent: _urgent,
      note: _noteController.text.trim(),
    );

    await app.addComplaint(complaint);
    final opened = await ContactService.whatsApp(ContactService.complaintMessage(complaint, app.vendor));
    if (!mounted) return;

    // ScaffoldMessenger पूरे ऐप का है, इसलिए संदेश पिछली स्क्रीन पर भी दिखता रहेगा।
    showMessage(
      context,
      opened ? 'शिकायत दर्ज हो गई' : 'शिकायत फ़ोन में दर्ज हो गई। $whatsAppFailedMessage',
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final firmName = AppScope.of(context).vendor.firmName;
    // शिकायत की तारीख से आज तक के दिन (दोनों सिर्फ़ तारीख, समय नहीं)।
    final days = _today().difference(_complaintDate).inDays;

    return Scaffold(
      appBar: AppBar(title: const Text('नई शिकायत')),
      // ListView नहीं: वह स्क्रीन से बाहर के खाने हटा देता है और तब उनकी जाँच नहीं होती।
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(AppSpace.l, AppSpace.l, AppSpace.l, AppSpace.xl),
        child: Form(
          key: _formKey,
          autovalidateMode: _triedSubmit ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InfoBanner(
                text: firmName.isEmpty
                    ? 'शिकायत WhatsApp पर हमारे पास आएगी। विज़िट आपके नाम से होगी, फ़ोटो सबूत के साथ।'
                    : 'शिकायत "$firmName" के नाम से WhatsApp पर हमारे पास आएगी। विज़िट आपके नाम से होगी, फ़ोटो सबूत के साथ।',
              ),

              // ग्राहक
              const SectionHeader('ग्राहक की जानकारी'),
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                style: AppText.body,
                decoration: const InputDecoration(
                  labelText: 'ग्राहक का नाम *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (v) => _required(v, 'ग्राहक का नाम लिखें'),
              ),
              const SizedBox(height: AppSpace.l),
              TextFormField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                style: AppText.body,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                decoration: const InputDecoration(
                  labelText: 'ग्राहक का मोबाइल *',
                  hintText: '10 अंक का नंबर',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                validator: _validateMobile,
              ),
              const SizedBox(height: AppSpace.l),
              TextFormField(
                controller: _addressController,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                minLines: 2,
                maxLines: 4,
                style: AppText.body,
                decoration: const InputDecoration(
                  labelText: 'पूरा पता *',
                  hintText: 'मकान नंबर, गली, मोहल्ला, पास की पहचान',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
                validator: (v) => _required(v, 'ग्राहक का पूरा पता लिखें'),
              ),
              const SizedBox(height: AppSpace.l),
              AreaField(
                value: _area,
                errorText: _areaError,
                onChanged: (a) => setState(() {
                  _area = a;
                  _areaError = null;
                }),
              ),

              // सिस्टम और दिक्कत
              const SectionHeader('सिस्टम और दिक्कत'),
              const Text('सिस्टम कितने kW का है?', style: AppText.h3),
              const SizedBox(height: AppSpace.s),
              KwSelector(value: _kw, onChanged: (kw) => setState(() => _kw = kw)),
              const SizedBox(height: AppSpace.xl),
              const Text('दिक्कत क्या है? *', style: AppText.h3),
              const SizedBox(height: AppSpace.s),
              OptionChips(
                options: Catalog.problems,
                selected: _problem,
                onChanged: (p) => setState(() {
                  _problem = p;
                  _problemError = null;
                }),
              ),
              if (_problemError != null) ...[
                const SizedBox(height: AppSpace.s),
                Text(
                  _problemError!,
                  style: const TextStyle(color: AppColors.danger, fontSize: 13),
                ),
              ],

              // पोर्टल
              const SectionHeader('पोर्टल की शिकायत'),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _sending ? null : _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'शिकायत की तारीख',
                    helperText: 'जिस दिन ग्राहक ने पोर्टल पर शिकायत की। 8 दिन की गिनती इसी से।',
                    helperMaxLines: 2,
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                    suffixIcon: Icon(Icons.expand_more),
                  ),
                  child: Text(hindiDate(_complaintDate), style: AppText.body),
                ),
              ),
              if (days >= portalWarningDays && !_urgent) ...[
                const SizedBox(height: AppSpace.m),
                InfoBanner(
                  tone: days >= portalReminderDays ? ChipTone.danger : ChipTone.warning,
                  icon: Icons.warning_amber_rounded,
                  text: 'शिकायत को $days दिन हो गए हैं। नीचे "जल्दी चाहिए" चालू कर दें।',
                ),
              ],
              const SizedBox(height: AppSpace.l),
              TextFormField(
                controller: _portalIdController,
                textInputAction: TextInputAction.next,
                style: AppText.body,
                decoration: const InputDecoration(
                  labelText: 'पोर्टल शिकायत नंबर (वैकल्पिक)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.receipt_long_outlined),
                ),
              ),
              const SizedBox(height: AppSpace.l),
              AppCard(
                padding: const EdgeInsets.symmetric(vertical: AppSpace.xs),
                borderColor: _urgent ? AppColors.sun : AppColors.border,
                color: _urgent ? AppColors.sunSoft : AppColors.card,
                child: SwitchListTile(
                  value: _urgent,
                  onChanged: (v) => setState(() => _urgent = v),
                  title: const Text('जल्दी चाहिए (48 घंटे में विज़िट)', style: AppText.h3),
                  subtitle: const Text(
                    'शिकायत पुरानी हो या ग्राहक नाराज़ हो तो चालू करें। इसका रेट सामान्य से थोड़ा ज़्यादा है।',
                    style: AppText.small,
                  ),
                ),
              ),
              const SizedBox(height: AppSpace.l),
              TextFormField(
                controller: _noteController,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                minLines: 2,
                maxLines: 4,
                style: AppText.body,
                decoration: const InputDecoration(
                  labelText: 'नोट (वैकल्पिक)',
                  hintText: 'जैसे: ग्राहक सुबह 10 बजे के बाद घर पर मिलेंगे',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomActionBar(
        child: AppButton(
          label: _sending ? 'भेजा जा रहा है…' : 'WhatsApp पर शिकायत भेजें',
          icon: Icons.send,
          onPressed: _sending ? null : _submit,
        ),
      ),
    );
  }
}
