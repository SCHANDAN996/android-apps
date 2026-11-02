import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:kaajo_core/app/app_scope.dart';
import 'package:kaajo_core/app/theme.dart';
import 'package:kaajo_core/content/config.dart';
import 'package:kaajo_core/models/profiles.dart';
import 'package:kaajo_core/utils/format.dart';
import 'package:kaajo_core/widgets/common.dart';
import 'widgets/partner_brand.dart';

/// वेंडर की फ़र्म की जानकारी।
/// [firstTime] true हो तो यह ऐप की पहली स्क्रीन है (RootGate से), कोई "वापस" नहीं।
/// सेव होते ही RootGate ख़ुद वेंडर होम दिखा देता है।
class VendorProfileScreen extends StatefulWidget {
  const VendorProfileScreen({super.key, this.firstTime = false});

  final bool firstTime;

  @override
  State<VendorProfileScreen> createState() => _VendorProfileScreenState();
}

class _VendorProfileScreenState extends State<VendorProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firmController = TextEditingController();
  final _personController = TextEditingController();
  final _mobileController = TextEditingController();

  bool _prefilled = false;
  bool _saving = false;
  bool _triedSave = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_prefilled) return;
    _prefilled = true;
    final v = AppScope.read(context).vendor;
    _firmController.text = v.firmName;
    _personController.text = v.contactPerson;
    _mobileController.text = _tenDigits(v.mobile);
  }

  @override
  void dispose() {
    _firmController.dispose();
    _personController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  /// सेव किया नंबर 91 के साथ हो तो आख़िरी 10 अंक।
  static String _tenDigits(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 10) return digits.substring(digits.length - 10);
    return digits;
  }

  String? _validateFirm(String? value) {
    if ((value ?? '').trim().isEmpty) return 'फ़र्म का नाम लिखें';
    return null;
  }

  String? _validateMobile(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'मोबाइल नंबर लिखें';
    if (v.length != 10 || !isValidMobile(v)) return 'सही 10 अंक का मोबाइल नंबर लिखें';
    return null;
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    setState(() => _triedSave = true);
    final formOk = _formKey.currentState?.validate() ?? false;
    final ok = formOk &&
        _validateFirm(_firmController.text) == null &&
        _validateMobile(_mobileController.text) == null;
    if (!ok) return;

    setState(() => _saving = true);
    final app = AppScope.read(context);
    await app.saveVendor(VendorProfile(
      firmName: _firmController.text.trim(),
      contactPerson: _personController.text.trim(),
      mobile: _mobileController.text.trim(),
    ));
    if (!mounted) return;
    setState(() => _saving = false);

    // पहली बार: RootGate अपने-आप वेंडर होम पर ले जाएगा।
    if (widget.firstTime) return;

    showMessage(context, 'फ़र्म की जानकारी सेव हो गई');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final firstTime = widget.firstTime;
    return Scaffold(
      appBar: firstTime ? null : AppBar(title: const Text('फ़र्म की जानकारी')),
      // ListView नहीं: वह स्क्रीन से बाहर के खाने हटा देता है और तब उनकी जाँच नहीं होती।
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AppSpace.l, AppSpace.l, AppSpace.l, AppSpace.xl),
          child: Form(
            key: _formKey,
            autovalidateMode: _triedSave ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (firstTime) const _WelcomeHeader() else const _EditIntro(),
                const SizedBox(height: AppSpace.xl),
                TextFormField(
                  controller: _firmController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  style: AppText.body,
                  decoration: const InputDecoration(
                    labelText: 'फ़र्म का नाम *',
                    hintText: 'जैसे: शिव सोलर एनर्जी',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.business),
                  ),
                  validator: _validateFirm,
                ),
                const SizedBox(height: AppSpace.l),
                TextFormField(
                  controller: _personController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  style: AppText.body,
                  decoration: const InputDecoration(
                    labelText: 'संपर्क व्यक्ति (वैकल्पिक)',
                    hintText: 'आपका नाम',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: AppSpace.l),
                TextFormField(
                  controller: _mobileController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  style: AppText.body,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'मोबाइल नंबर *',
                    hintText: '10 अंक का नंबर',
                    helperText: 'इसी नंबर पर हम विज़िट की जानकारी देंगे',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: _validateMobile,
                  onFieldSubmitted: (_) {
                    if (!_saving) _save();
                  },
                ),
                if (firstTime) ...[
                  const SizedBox(height: AppSpace.l),
                  Center(
                    child: TextButton(
                      onPressed: () => AppScope.read(context).clearRole(),
                      child: const Text('ग़लत भूमिका चुनी? वापस जाएँ'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomActionBar(
        child: AppButton(
          label: _saving ? 'सेव हो रहा है…' : (firstTime ? 'सेव करें और आगे बढ़ें' : 'सेव करें'),
          icon: Icons.check,
          onPressed: _saving ? null : _save,
        ),
      ),
    );
  }
}

/// पहली बार खुलने पर स्वागत।
class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppSpace.s),
        Container(
          padding: const EdgeInsets.all(AppSpace.m),
          decoration: const BoxDecoration(color: AppColors.sun, shape: BoxShape.circle),
          child: const Icon(Icons.solar_power, size: 32, color: Colors.white),
        ),
        const SizedBox(height: AppSpace.l),
        const Text('नमस्ते! $partnerAppName में स्वागत है', style: AppText.h1),
        const SizedBox(height: AppSpace.s),
        const Text(
          AppConfig.vendorLine,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary, height: 1.35),
        ),
        const SizedBox(height: AppSpace.m),
        const Text(
          'शुरू करने के लिए अपनी फ़र्म की जानकारी भरें। यह हर शिकायत के साथ हमारे पास आएगी, '
          'ताकि हम आपके नाम से ग्राहक के घर जाएँ।',
          style: AppText.muted,
        ),
      ],
    );
  }
}

/// सेटिंग से खोलने पर छोटी जानकारी।
class _EditIntro extends StatelessWidget {
  const _EditIntro();

  @override
  Widget build(BuildContext context) {
    return const InfoBanner(
      text: 'यह जानकारी हर शिकायत के साथ हमारे पास आती है, ताकि हम आपके नाम से ग्राहक के घर जाएँ।',
    );
  }
}
