import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:kaajo_core/app/app_scope.dart';
import 'package:kaajo_core/app/theme.dart';
import 'package:kaajo_core/content/config.dart';
import 'package:kaajo_core/models/profiles.dart';
import 'package:kaajo_core/utils/format.dart';
import 'package:kaajo_core/widgets/common.dart';
import 'package:kaajo_core/widgets/pickers.dart';

/// योग्यता के विकल्प।
const List<String> technicianQualifications = [
  'ITI इलेक्ट्रीशियन',
  'ITI वायरमैन',
  'सूर्य मित्र',
  '10वीं/12वीं',
  'कोई और',
];

/// टेक्नीशियन का अकाउंट बनाना / जानकारी बदलना।
/// [firstTime] true हो तो यह RootGate से खुली पहली स्क्रीन है (कोई "वापस" नहीं);
/// सेव होते ही RootGate अपने-आप ट्रेनिंग दिखा देता है।
/// [firstTime] false (सेटिंग से): सेव के बाद स्क्रीन बंद।
class TechnicianSignupScreen extends StatefulWidget {
  const TechnicianSignupScreen({super.key, this.firstTime = false});

  final bool firstTime;

  @override
  State<TechnicianSignupScreen> createState() => _TechnicianSignupScreenState();
}

class _TechnicianSignupScreenState extends State<TechnicianSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();

  String _area = '';
  String _qualification = '';
  bool _hasScooty = false;

  bool _prefilled = false;
  bool _saving = false;
  bool _triedSave = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_prefilled) return;
    _prefilled = true;
    final t = AppScope.read(context).technician;
    _nameController.text = t.name;
    _mobileController.text = _tenDigits(t.mobile);
    _area = t.area;
    _qualification = t.qualification;
    _hasScooty = t.hasScooty;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  /// सेव किया नंबर 91 के साथ हो तो आख़िरी 10 अंक।
  static String _tenDigits(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 10) return digits.substring(digits.length - 10);
    return digits;
  }

  String? _validateName(String? value) {
    if ((value ?? '').trim().isEmpty) return 'अपना नाम लिखें';
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
        _validateName(_nameController.text) == null &&
        _validateMobile(_mobileController.text) == null;
    if (!ok) {
      showMessage(context, 'कृपया लाल निशान वाली जानकारी ठीक करें');
      return;
    }

    setState(() => _saving = true);
    final app = AppScope.read(context);
    final existing = app.technician;
    await app.saveTechnician(TechnicianProfile(
      name: _nameController.text.trim(),
      mobile: _mobileController.text.trim(),
      area: _area,
      qualification: _qualification,
      hasScooty: _hasScooty,
      joinedAt: existing.joinedAt ?? DateTime.now(),
    ));
    if (!mounted) return;
    setState(() => _saving = false);

    // पहली बार: RootGate अपने-आप ट्रेनिंग वाली स्क्रीन पर ले जाएगा।
    if (widget.firstTime) return;

    showMessage(context, 'आपकी जानकारी सेव हो गई');
    Navigator.of(context).pop();
  }

  Future<void> _wrongRole() async {
    await AppScope.read(context).clearRole();
    // RootGate अपने-आप भूमिका वाली स्क्रीन दिखा देगा।
  }

  @override
  Widget build(BuildContext context) {
    final firstTime = widget.firstTime;
    return Scaffold(
      appBar: firstTime ? null : AppBar(title: const Text('मेरी जानकारी')),
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
                if (firstTime) const _WelcomeHeader(),
                if (firstTime) const SizedBox(height: AppSpace.xl),
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  style: AppText.body,
                  decoration: const InputDecoration(
                    labelText: 'आपका नाम *',
                    hintText: 'जैसे: राजेश कुमार',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: _validateName,
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
                    helperText: 'इसी नंबर पर मालिक आपसे बात करेंगे',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: _validateMobile,
                ),
                const SizedBox(height: AppSpace.l),
                AreaField(
                  value: _area,
                  onChanged: (a) => setState(() => _area = a),
                ),
                const SizedBox(height: AppSpace.xs),
                const Text('आप किस इलाके में रहते हैं या काम कर सकते हैं', style: AppText.small),
                const SizedBox(height: AppSpace.xl),
                const Text('आपकी योग्यता', style: AppText.h3),
                const SizedBox(height: AppSpace.s),
                OptionChips(
                  options: technicianQualifications,
                  selected: _qualification,
                  onChanged: (q) => setState(() => _qualification = q),
                ),
                const SizedBox(height: AppSpace.xl),
                AppCard(
                  padding: const EdgeInsets.symmetric(vertical: AppSpace.xs),
                  borderColor: _hasScooty ? AppColors.primary : AppColors.border,
                  color: _hasScooty ? AppColors.primarySoft : AppColors.card,
                  child: SwitchListTile(
                    value: _hasScooty,
                    onChanged: (v) => setState(() => _hasScooty = v),
                    secondary: const Icon(Icons.two_wheeler, color: AppColors.primary),
                    title: const Text('मेरे पास स्कूटी है', style: AppText.h3),
                    subtitle: const Text('ग्राहकों के घर जाने के लिए', style: AppText.small),
                  ),
                ),
                const SizedBox(height: AppSpace.xl),
                const InfoBanner(
                  icon: Icons.phone_android,
                  text: 'अभी (वर्ज़न ${AppConfig.version}) आपकी जानकारी और ट्रेनिंग सिर्फ़ इसी फ़ोन में सेव होती है। '
                      'मोबाइल OTP से लॉगिन अगले वर्ज़न में आएगा।',
                ),
                if (firstTime) ...[
                  const SizedBox(height: AppSpace.l),
                  Center(
                    child: TextButton(
                      onPressed: _saving ? null : _wrongRole,
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
          label: _saving ? 'सेव हो रहा है…' : (firstTime ? 'अकाउंट बनाएँ और ट्रेनिंग शुरू करें' : 'सेव करें'),
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
          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
          child: const Icon(Icons.engineering, size: 32, color: Colors.white),
        ),
        const SizedBox(height: AppSpace.l),
        const Text('अपना अकाउंट बनाएँ', style: AppText.h1),
        const SizedBox(height: AppSpace.s),
        const Text(
          'काजो टीम में स्वागत है!',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.primary, height: 1.35),
        ),
        const SizedBox(height: AppSpace.m),
        const Text(
          'अपनी जानकारी भरें। उसके बाद आपकी पूरी ट्रेनिंग इसी ऐप में होगी: रोज़ के पाठ, क्विज़, '
          'मालिक के साथ फ़ील्ड ट्रायल, और आख़िर में सर्टिफ़िकेट।',
          style: AppText.muted,
        ),
      ],
    );
  }
}
