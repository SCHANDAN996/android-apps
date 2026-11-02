import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nischint_core/app/app_scope.dart';
import 'package:nischint_core/app/app_state.dart';
import 'package:nischint_core/app/theme.dart';
import 'package:nischint_core/content/catalog.dart';
import 'package:nischint_core/content/config.dart';
import 'package:nischint_core/models/booking.dart';
import 'package:nischint_core/models/profiles.dart';
import 'package:nischint_core/models/service_item.dart';
import 'package:nischint_core/services/contact_service.dart';
import 'package:nischint_core/utils/format.dart';
import 'package:nischint_core/widgets/common.dart';
import 'package:nischint_core/widgets/pickers.dart';

import 'booking_success_screen.dart';
import 'widgets/customer_bits.dart';

/// बुकिंग के 3 स्टेप: 1 सिस्टम → 2 पता और समय → 3 पुष्टि।
/// पिछली बार भरी जानकारी (नाम, मोबाइल, पता, kW) अपने-आप भरी मिलती है।
class BookingFormScreen extends StatefulWidget {
  const BookingFormScreen({super.key, required this.service});

  final ServiceItem service;

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  static const List<String> _stepLabels = ['सिस्टम', 'पता और समय', 'पुष्टि'];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late final TextEditingController _vendor;
  late final TextEditingController _name;
  late final TextEditingController _mobile;
  late final TextEditingController _address;
  late final TextEditingController _landmark;
  late final List<DateTime> _days;

  int _step = 0;
  int _kw = 3;
  String _problem = '';
  String _area = '';
  DateTime? _date;
  String _timeSlot = '';
  bool _sending = false;

  bool _problemError = false;
  bool _areaError = false;
  bool _dateError = false;
  bool _timeError = false;

  /// स्टेप 2 में एक बार "आगे" दबाने के बाद ग़लतियाँ लिखते-लिखते ठीक होती दिखें।
  bool _addressTried = false;

  ServiceItem get _service => widget.service;
  bool get _isCleaning => _service.id == 'solar_cleaning';
  bool get _isLastStep => _step == _stepLabels.length - 1;

  @override
  void initState() {
    super.initState();
    final app = AppScope.read(context);
    final c = app.customer;
    var lastVendor = '';
    for (final b in app.bookings) {
      if (b.installerVendor.isNotEmpty) {
        lastVendor = b.installerVendor;
        break;
      }
    }
    _vendor = TextEditingController(text: lastVendor);
    _name = TextEditingController(text: c.name);
    _mobile = TextEditingController(text: c.mobile);
    _address = TextEditingController(text: c.address);
    _landmark = TextEditingController(text: c.landmark);
    _area = c.area;
    _kw = Catalog.kwOptions.contains(c.systemKw) ? c.systemKw : 3;
    _days = nextDays(7);
  }

  @override
  void dispose() {
    _vendor.dispose();
    _name.dispose();
    _mobile.dispose();
    _address.dispose();
    _landmark.dispose();
    super.dispose();
  }

  // ---------------- स्टेप बदलना ----------------

  void _goBack() {
    FocusScope.of(context).unfocus();
    if (_step == 0) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _step -= 1);
  }

  void _goNext() {
    FocusScope.of(context).unfocus();
    if (_step == 0 && !_checkSystemStep()) return;
    if (_step == 1 && !_checkAddressStep()) return;
    if (_isLastStep) return;
    setState(() => _step += 1);
  }

  bool _checkSystemStep() {
    final missingProblem = _service.needsProblem && _problem.isEmpty;
    setState(() => _problemError = missingProblem);
    if (missingProblem) {
      showMessage(context, 'आगे बढ़ने से पहले दिक्कत चुनें');
      return false;
    }
    return true;
  }

  bool _checkAddressStep() {
    final fieldsOk = _formKey.currentState?.validate() ?? false;
    setState(() {
      _addressTried = true;
      _areaError = _area.isEmpty;
      _dateError = _date == null;
      _timeError = _timeSlot.isEmpty;
    });
    if (!fieldsOk || _areaError || _dateError || _timeError) {
      showMessage(context, 'कुछ जानकारी बाक़ी है। लाल रंग में लिखी जगह भरें।');
      return false;
    }
    return true;
  }

  // ---------------- भेजना ----------------

  Future<void> _submit() async {
    if (_sending) return;
    final date = _date;
    if (date == null || _timeSlot.isEmpty || _area.isEmpty) {
      setState(() => _step = 1);
      showMessage(context, 'तारीख, समय और इलाका चुनें');
      return;
    }
    setState(() => _sending = true);

    final app = AppScope.read(context);
    final name = _name.text.trim();
    final mobile = _mobile.text.trim();
    final address = _address.text.trim();
    final landmark = _landmark.text.trim();
    final booking = Booking(
      id: AppState.newBookingId(),
      serviceId: _service.id,
      serviceTitle: _service.title,
      customerName: name,
      mobile: mobile,
      address: address,
      area: _area,
      landmark: landmark,
      systemKw: _kw,
      problem: _service.needsProblem ? _problem : '',
      installerVendor: _vendor.text.trim(),
      date: date,
      timeSlot: _timeSlot,
      estimatedPrice: _service.estimateFor(_kw),
      createdAt: DateTime.now(),
    );

    // पहले फ़ोन में सेव, ताकि WhatsApp न खुले तब भी बुकिंग "मेरी बुकिंग" में रहे।
    // (यहाँ context इस्तेमाल नहीं होता, इसलिए दोनों काम बिना रुकावट पूरे होते हैं।)
    try {
      await app.saveCustomer(CustomerProfile(
        name: name,
        mobile: mobile,
        address: address,
        area: _area,
        landmark: landmark,
        systemKw: _kw,
      ));
      await app.addBooking(booking);
    } catch (_) {
      // फ़ोन में सेव न हो पाए तब भी WhatsApp पर भेजने की कोशिश करें।
    }
    if (!mounted) return;

    final opened = await ContactService.whatsApp(ContactService.bookingMessage(booking));
    if (!mounted) return;
    if (!opened) showMessage(context, whatsAppFailedMessage);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => BookingSuccessScreen(booking: booking)),
    );
  }

  // ---------------- स्क्रीन ----------------

  @override
  Widget build(BuildContext context) {
    return PopScope<Object?>(
      canPop: _step == 0 && !_sending,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop || _sending) return;
        _goBack();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(_service.title)),
        body: Column(
          children: [
            _StepHeader(labels: _stepLabels, current: _step),
            Expanded(
              child: SingleChildScrollView(
                key: ValueKey<int>(_step),
                padding: const EdgeInsets.fromLTRB(AppSpace.l, AppSpace.l, AppSpace.l, AppSpace.xl),
                child: switch (_step) {
                  0 => _buildSystemStep(),
                  1 => _buildAddressStep(),
                  _ => _buildConfirmStep(),
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomActionBar(child: _buildActions()),
      ),
    );
  }

  Widget _buildActions() {
    VoidCallback? onPrimary;
    if (!_sending) {
      onPrimary = _isLastStep ? () => _submit() : _goNext;
    }
    final primary = PairButton(
      label: _isLastStep
          ? (_sending ? 'भेज रहे हैं…' : 'WhatsApp पर बुकिंग भेजें')
          : 'आगे',
      icon: _isLastStep ? Icons.send : Icons.arrow_forward,
      onPressed: onPrimary,
    );
    if (_step == 0) {
      return SizedBox(width: double.infinity, child: primary);
    }
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: PairButton(
            label: 'पीछे',
            icon: Icons.arrow_back,
            outlined: true,
            onPressed: _sending ? null : _goBack,
          ),
        ),
        const SizedBox(width: AppSpace.m),
        Expanded(flex: _isLastStep ? 5 : 3, child: primary),
      ],
    );
  }

  /// स्टेप 1: सिस्टम कितने kW, दिक्कत (रिपेयर में), किसने लगाया।
  Widget _buildSystemStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('आपका सोलर सिस्टम कितने kW का है?', style: AppText.h3),
        const SizedBox(height: AppSpace.xs),
        const Text('पक्का पता न हो तो अंदाज़े से चुन लें, हम कॉल पर पूछ लेंगे।', style: AppText.small),
        const SizedBox(height: AppSpace.m),
        KwSelector(value: _kw, onChanged: (kw) => setState(() => _kw = kw)),
        const SizedBox(height: AppSpace.l),
        AppCard(
          color: AppColors.primarySoft,
          borderColor: AppColors.primarySoft,
          padding: const EdgeInsets.all(AppSpace.m),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.currency_rupee, color: AppColors.primary, size: 22),
              const SizedBox(width: AppSpace.s),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'अनुमानित रेट: ${rupees(_service.estimateFor(_kw))}',
                      style: AppText.h3.copyWith(color: AppColors.primaryDark),
                    ),
                    if (_service.priceNote.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(_service.priceNote, style: AppText.small),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_service.needsProblem) ...[
          const SizedBox(height: AppSpace.xl),
          const Text('क्या दिक्कत है?', style: AppText.h3),
          const SizedBox(height: AppSpace.m),
          OptionChips(
            options: Catalog.problems,
            selected: _problem,
            onChanged: (p) => setState(() {
              _problem = p;
              _problemError = false;
            }),
          ),
          if (_problemError) const FieldErrorText('दिक्कत चुनें'),
        ],
        const SizedBox(height: AppSpace.xl),
        TextField(
          controller: _vendor,
          textCapitalization: TextCapitalization.words,
          style: AppText.body,
          decoration: const InputDecoration(
            labelText: 'किस वेंडर ने लगाया? (वैकल्पिक)',
            hintText: 'कंपनी या दुकान का नाम',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  /// स्टेप 2: नाम, मोबाइल, पता, इलाका, तारीख और समय।
  Widget _buildAddressStep() {
    final dayLabels = [for (final d in _days) dateChipLabel(d)];
    final date = _date;
    return Form(
      key: _formKey,
      autovalidateMode:
          _addressTried ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('आपकी जानकारी', style: AppText.h3),
          const SizedBox(height: AppSpace.m),
          TextFormField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            style: AppText.body,
            decoration: const InputDecoration(labelText: 'नाम', border: OutlineInputBorder()),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'अपना नाम लिखें' : null,
          ),
          const SizedBox(height: AppSpace.l),
          TextFormField(
            controller: _mobile,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            maxLength: 10,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: AppText.body,
            decoration: const InputDecoration(
              labelText: 'मोबाइल नंबर',
              hintText: '10 अंक का नंबर',
              border: OutlineInputBorder(),
            ),
            validator: (v) => isValidMobile(v ?? '') ? null : 'सही 10 अंक का मोबाइल नंबर लिखें',
          ),
          const SizedBox(height: AppSpace.s),
          TextFormField(
            controller: _address,
            keyboardType: TextInputType.multiline,
            minLines: 2,
            maxLines: 4,
            style: AppText.body,
            decoration: const InputDecoration(
              labelText: 'पूरा पता',
              hintText: 'मकान नंबर, गली, मोहल्ला',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
            validator: (v) => (v == null || v.trim().length < 5) ? 'पूरा पता लिखें' : null,
          ),
          const SizedBox(height: AppSpace.l),
          TextFormField(
            controller: _landmark,
            textInputAction: TextInputAction.done,
            style: AppText.body,
            decoration: const InputDecoration(
              labelText: 'लैंडमार्क (वैकल्पिक)',
              hintText: 'जैसे: मंदिर, स्कूल या दुकान के पास',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: AppSpace.l),
          AreaField(
            value: _area,
            errorText: _areaError ? 'अपना इलाका चुनें' : null,
            onChanged: (a) => setState(() {
              _area = a;
              _areaError = false;
            }),
          ),
          const SizedBox(height: AppSpace.xl),
          const Text('किस दिन आएँ?', style: AppText.h3),
          const SizedBox(height: AppSpace.m),
          OptionChips(
            options: dayLabels,
            selected: date == null ? '' : dateChipLabel(date),
            onChanged: (label) {
              final i = dayLabels.indexOf(label);
              if (i < 0) return;
              setState(() {
                _date = _days[i];
                _dateError = false;
              });
            },
          ),
          if (date != null)
            Padding(
              padding: const EdgeInsets.only(top: AppSpace.s),
              child: Text('चुनी तारीख: ${hindiDate(date)}', style: AppText.small),
            ),
          if (_dateError) const FieldErrorText('तारीख चुनें'),
          const SizedBox(height: AppSpace.xl),
          const Text('किस समय आएँ?', style: AppText.h3),
          const SizedBox(height: AppSpace.m),
          if (_isCleaning) ...[
            const InfoBanner(
              text: 'सुबह या शाम सबसे अच्छा — दोपहर में गर्म पैनल पर पानी नहीं डालते',
              icon: Icons.wb_sunny_outlined,
              tone: ChipTone.warning,
            ),
            const SizedBox(height: AppSpace.m),
          ],
          OptionChips(
            options: Catalog.timeSlots,
            selected: _timeSlot,
            onChanged: (t) => setState(() {
              _timeSlot = t;
              _timeError = false;
            }),
          ),
          if (_timeError) const FieldErrorText('समय चुनें'),
        ],
      ),
    );
  }

  /// स्टेप 3: पूरी जानकारी का सार, अनुमानित रेट और "पैसा काम के बाद"।
  Widget _buildConfirmStep() {
    final date = _date;
    final vendor = _vendor.text.trim();
    final landmark = _landmark.text.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('एक बार जाँच लें', style: AppText.h2),
        const SizedBox(height: AppSpace.xs),
        const Text(
          'सब ठीक हो तो नीचे का बटन दबाएँ। कुछ बदलना हो तो "पीछे" दबाएँ।',
          style: AppText.muted,
        ),
        const SizedBox(height: AppSpace.l),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconBubble(_service.icon, size: 44),
                  const SizedBox(width: AppSpace.m),
                  Expanded(child: Text(_service.title, style: AppText.h3)),
                ],
              ),
              const Divider(height: AppSpace.xl),
              DetailRow(label: 'सिस्टम', value: Catalog.kwLabel(_kw), icon: Icons.solar_power),
              if (_service.needsProblem)
                DetailRow(label: 'दिक्कत', value: _problem, icon: Icons.report_problem_outlined),
              if (vendor.isNotEmpty)
                DetailRow(label: 'किसने लगाया', value: vendor, icon: Icons.storefront_outlined),
              DetailRow(
                label: 'तारीख',
                value: date == null ? '' : hindiDate(date),
                icon: Icons.calendar_today,
              ),
              DetailRow(label: 'समय', value: _timeSlot, icon: Icons.schedule),
              const Divider(height: AppSpace.xl),
              DetailRow(label: 'नाम', value: _name.text.trim(), icon: Icons.person_outline),
              DetailRow(label: 'मोबाइल', value: _mobile.text.trim(), icon: Icons.phone_outlined),
              DetailRow(label: 'पता', value: _address.text.trim(), icon: Icons.home_outlined),
              if (landmark.isNotEmpty)
                DetailRow(label: 'लैंडमार्क', value: landmark, icon: Icons.place_outlined),
              DetailRow(label: 'इलाका', value: _area, icon: Icons.location_on_outlined),
            ],
          ),
        ),
        const SizedBox(height: AppSpace.l),
        AppCard(
          color: AppColors.primarySoft,
          borderColor: AppColors.primarySoft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('अनुमानित रेट', style: AppText.small),
              const SizedBox(height: 2),
              Text(
                rupees(_service.estimateFor(_kw)),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primaryDark,
                ),
              ),
              if (_service.priceNote.isNotEmpty) ...[
                const SizedBox(height: AppSpace.xs),
                Text(_service.priceNote, style: AppText.small),
              ],
              const SizedBox(height: AppSpace.m),
              const Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.success, size: 20),
                  SizedBox(width: AppSpace.s),
                  Expanded(
                    child: Text(
                      'पैसा काम के बाद — पहले कोई पैसा नहीं',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpace.l),
        InfoBanner(
          text: 'बटन दबाने पर WhatsApp खुलेगा, वहाँ मैसेज का "भेजें" बटन ज़रूर दबाएँ। '
              '${AppConfig.callbackPromise}',
          icon: Icons.chat,
        ),
      ],
    );
  }
}

/// ऊपर की 3 स्टेप वाली पट्टी: 1 सिस्टम · 2 पता और समय · 3 पुष्टि।
class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.labels, required this.current});

  final List<String> labels;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(AppSpace.l, AppSpace.m, AppSpace.l, AppSpace.m),
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < labels.length; i++)
                Expanded(
                  child: _StepDot(
                    number: i + 1,
                    label: labels[i],
                    done: i < current,
                    active: i == current,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpace.m),
          Row(
            children: [
              for (var i = 0; i < labels.length; i++)
                Expanded(
                  child: Container(
                    height: 4,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      color: i <= current ? AppColors.primary : AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({
    required this.number,
    required this.label,
    required this.done,
    required this.active,
  });

  final int number;
  final String label;
  final bool done;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final filled = done || active;
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: filled ? AppColors.primary : AppColors.card,
            shape: BoxShape.circle,
            border: Border.all(color: filled ? AppColors.primary : AppColors.border, width: 1.5),
          ),
          child: done
              ? const Icon(Icons.check, size: 18, color: Colors.white)
              : Text(
                  '$number',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: active ? Colors.white : AppColors.textMuted,
                  ),
                ),
        ),
        const SizedBox(height: AppSpace.xs),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
            color: active
                ? AppColors.primaryDark
                : (done ? AppColors.text : AppColors.textMuted),
          ),
        ),
      ],
    );
  }
}
