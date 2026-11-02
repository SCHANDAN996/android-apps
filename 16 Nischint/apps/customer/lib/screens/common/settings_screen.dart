import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nischint_core/app/app_scope.dart';
import 'package:nischint_core/app/theme.dart';
import 'package:nischint_core/content/config.dart';
import 'package:nischint_core/models/profiles.dart';
import 'package:nischint_core/utils/format.dart';
import 'package:nischint_core/widgets/common.dart';
import 'package:nischint_core/widgets/pickers.dart';

/// ग्राहक ऐप की सेटिंग: अपनी जानकारी, डेटा मिटाना, ऐप के बारे में।
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final c = app.customer;
    return Scaffold(
      appBar: AppBar(title: const Text('सेटिंग')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpace.l),
        children: [
          const SectionHeader('आपकी जानकारी'),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (c.isEmpty)
                  const Text('अभी कोई जानकारी सेव नहीं है। पहली बुकिंग पर अपने-आप सेव हो जाएगी।',
                      style: AppText.muted)
                else ...[
                  Text(c.name, style: AppText.h3),
                  const SizedBox(height: AppSpace.xs),
                  Text(c.mobile, style: AppText.body),
                  if (c.address.isNotEmpty) ...[
                    const SizedBox(height: AppSpace.xs),
                    Text([c.address, c.area].where((s) => s.isNotEmpty).join(', '), style: AppText.muted),
                  ],
                ],
                const SizedBox(height: AppSpace.m),
                AppButton(
                  label: c.isEmpty ? 'जानकारी भरें' : 'जानकारी बदलें',
                  icon: Icons.edit,
                  outlined: true,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(builder: (_) => const _CustomerProfileForm()),
                  ),
                ),
              ],
            ),
          ),
          const SectionHeader('डेटा'),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('फ़ोन में सेव आपकी सारी बुकिंग और जानकारी मिट जाएगी।', style: AppText.muted),
                const SizedBox(height: AppSpace.m),
                AppButton(
                  label: 'सारा डेटा मिटाएँ',
                  icon: Icons.delete_outline,
                  outlined: true,
                  color: AppColors.danger,
                  onPressed: () => _confirmClear(context),
                ),
              ],
            ),
          ),
          const SectionHeader('ऐप के बारे में'),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(AppConfig.appName, style: AppText.h2),
                const SizedBox(height: AppSpace.xs),
                const Text(AppConfig.tagline, style: AppText.body),
                const SizedBox(height: AppSpace.s),
                Text('वर्ज़न ${AppConfig.version} · सेवा क्षेत्र: ${AppConfig.serviceArea}', style: AppText.small),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.xl),
        ],
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('सारा डेटा मिटाएँ?'),
        content: const Text('आपकी सारी बुकिंग और जानकारी इस फ़ोन से हट जाएगी। यह वापस नहीं आएगी।'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('रहने दें')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('मिटाएँ', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final app = AppScope.read(context);
    Navigator.of(context).popUntil((r) => r.isFirst);
    await app.clearAll();
  }
}

/// नाम, मोबाइल, पता बदलने का फ़ॉर्म।
class _CustomerProfileForm extends StatefulWidget {
  const _CustomerProfileForm();

  @override
  State<_CustomerProfileForm> createState() => _CustomerProfileFormState();
}

class _CustomerProfileFormState extends State<_CustomerProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _mobile;
  late final TextEditingController _address;
  late final TextEditingController _landmark;
  String _area = '';
  int _kw = 3;
  bool _areaMissing = false;

  @override
  void initState() {
    super.initState();
    final c = AppScope.read(context).customer;
    _name = TextEditingController(text: c.name);
    _mobile = TextEditingController(text: c.mobile);
    _address = TextEditingController(text: c.address);
    _landmark = TextEditingController(text: c.landmark);
    _area = c.area;
    _kw = c.systemKw;
  }

  @override
  void dispose() {
    _name.dispose();
    _mobile.dispose();
    _address.dispose();
    _landmark.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final valid = _formKey.currentState?.validate() ?? false;
    setState(() => _areaMissing = _area.isEmpty);
    if (!valid || _area.isEmpty) return;
    await AppScope.read(context).saveCustomer(CustomerProfile(
      name: _name.text.trim(),
      mobile: _mobile.text.trim(),
      address: _address.text.trim(),
      area: _area,
      landmark: _landmark.text.trim(),
      systemKw: _kw,
    ));
    if (!mounted) return;
    showMessage(context, 'जानकारी सेव हो गई');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('आपकी जानकारी')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(AppSpace.l),
          children: [
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'नाम', border: OutlineInputBorder()),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'नाम लिखें' : null,
            ),
            const SizedBox(height: AppSpace.l),
            TextFormField(
              controller: _mobile,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(labelText: 'मोबाइल नंबर', border: OutlineInputBorder()),
              validator: (v) => isValidMobile(v ?? '') ? null : 'सही 10 अंक का मोबाइल नंबर लिखें',
            ),
            const SizedBox(height: AppSpace.s),
            TextFormField(
              controller: _address,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'पूरा पता', border: OutlineInputBorder()),
              validator: (v) => (v == null || v.trim().length < 5) ? 'पूरा पता लिखें' : null,
            ),
            const SizedBox(height: AppSpace.l),
            TextFormField(
              controller: _landmark,
              decoration: const InputDecoration(labelText: 'लैंडमार्क (वैकल्पिक)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: AppSpace.l),
            AreaField(
              value: _area,
              errorText: _areaMissing ? 'इलाका चुनें' : null,
              onChanged: (a) => setState(() {
                _area = a;
                _areaMissing = false;
              }),
            ),
            const SizedBox(height: AppSpace.xl),
            const Text('सोलर सिस्टम कितने kW का है?', style: AppText.h3),
            const SizedBox(height: AppSpace.s),
            KwSelector(value: _kw, onChanged: (kw) => setState(() => _kw = kw)),
            const SizedBox(height: AppSpace.xl),
          ],
        ),
      ),
      bottomNavigationBar: BottomActionBar(
        child: AppButton(label: 'सेव करें', icon: Icons.check, onPressed: _save),
      ),
    );
  }
}
