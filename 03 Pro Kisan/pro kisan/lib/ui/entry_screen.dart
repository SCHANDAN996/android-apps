import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../blocs/app_cubit.dart';
import '../../blocs/entry_cubit.dart';
import '../../blocs/customer_cubit.dart';
import '../../l10n/app_localizations.dart';
import '../../db/models/milk_entry.dart';
import '../../db/models/customer.dart';
import '../../services/notification_service.dart';
import 'widgets/pro_tour.dart';
import '../../db/dao/settings_dao.dart';
import 'main_shell.dart';
import 'theme/dairy_theme.dart';

class EntryScreen extends StatefulWidget {
  final MilkEntry? editEntry;
  const EntryScreen({super.key, this.editEntry});

  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  late DateTime _selectedDate;
  late String _shift; // 'M' or 'E'
  late String _direction; // 'sell' or 'buy'
  Customer? _selectedCustomer;
  String _qtyString = "";
  String _fatString = "";
  bool _editingFat = false; // toggles keypad input target

  final GlobalKey _dateKey = GlobalKey();
  final GlobalKey _directionKey = GlobalKey();
  final GlobalKey _qtyKey = GlobalKey();
  final GlobalKey _fatKey = GlobalKey();
  final GlobalKey _rateKey = GlobalKey();
  final GlobalKey _okKey = GlobalKey();

  double _computedAmount = 0.0;
  double _computedRate = 0.0;
  bool _isCustomRate = false;
  double _customRate = 0.0;

  /// select-screen की खोज पट्टी का text
  String _selectQuery = '';

  /// tour सिर्फ़ form दिखने पर, एक ही बार
  bool _tourChecked = false;

  @override
  void initState() {
    super.initState();

    final isEdit = widget.editEntry != null;
    _selectedDate = isEdit ? DateFormat('dd-MM-yyyy').parse(widget.editEntry!.date) : DateTime.now();
    _shift = isEdit ? widget.editEntry!.shift : _getDefaultShift();
    _direction = isEdit ? widget.editEntry!.direction : 'sell';
    _qtyString = isEdit ? widget.editEntry!.qtyL.toString() : "1.0";
    _fatString = isEdit && widget.editEntry!.fatPct != null ? widget.editEntry!.fatPct.toString() : "";

    // सीधा flow: नई एंट्री → पहले पूरी screen पर ग्राहक चुनो (build में
    // select-body), form उसके बाद। ठीक 1 ग्राहक हो तो वही अपने-आप चुनकर
    // सीधे form पर।
    final customerCubit = context.read<CustomerCubit>();
    if (customerCubit.state is! CustomerListLoaded) {
      customerCubit.loadCustomers();
    }
    final list = _allCustomers();
    if (isEdit) {
      final match =
          list.where((c) => c.id == widget.editEntry!.customerId).toList();
      _selectedCustomer = match.isNotEmpty ? match.first : null;
    } else if (list.length == 1) {
      _selectedCustomer = list.first;
      _qtyString = list.first.defaultQtyL.toString();
      _direction = list.first.partyType == 'supplier' ? 'buy' : 'sell';
    }

    _calculateLiveAmount();
  }

  /// CustomerCubit से सारे active ग्राहक (state loaded न हो तो ख़ाली)।
  List<Customer> _allCustomers() {
    final s = context.read<CustomerCubit>().state;
    if (s is CustomerListLoaded) return s.customers;
    return const [];
  }

  String _getDefaultShift() {
    final hour = DateTime.now().hour;
    return hour < 14 ? 'M' : 'E';
    }

  Future<void> _checkAndShowTour() async {
    final settings = SettingsDao();
    final hasSeen = await settings.hasSeenEntryTour();
    if (!hasSeen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Wait 500ms to ensure the layout has stabilized before showing tour
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _showTutorial();
          }
        });
      });
    }
  }

  /// एंट्री का रास्ता — पहली बार आने वाले किसान को
  ///
  /// एक क़दम में एक ही बात। घेरा अब चौकोर है और असली बटन जितना — देखें
  /// `ProTour`, वहीं यह सब तय होता है।
  void _showTutorial() {
    String t(String k) => AppLocalizations.get(context, k);

    ProTour.dikhao(
      context,
      steps: [
        ProTourStep(
          key: _dateKey,
          title: t('tour_entry_date_title'),
          desc: t('tour_entry_date_desc'),
        ),
        ProTourStep(
          key: _qtyKey,
          title: t('tour_entry_qty_title'),
          desc: t('tour_entry_qty_desc'),
        ),
        ProTourStep(
          key: _rateKey,
          title: t('tour_entry_rate_title'),
          desc: t('tour_entry_rate_desc'),
        ),
        ProTourStep(
          key: _okKey,
          title: t('tour_entry_ok_title'),
          desc: t('tour_entry_ok_desc'),
        ),
      ],
      onKhatam: () => SettingsDao().setSeenEntryTour(),
    );
  }

  void _calculateLiveAmount() {
    final appState = context.read<AppCubit>().state;
    final qty = double.tryParse(_qtyString) ?? 0.0;
    final fat = double.tryParse(_fatString) ?? 0.0;

    double rate = 0.0;
    
    if (_isCustomRate) {
      rate = _customRate;
    } else {
      String rateType = appState.rateType;

      if (_selectedCustomer != null) {
        rateType = _selectedCustomer!.rateType;
        rate = _selectedCustomer!.flatRate;
      } else {
        rate = appState.flatRate;
      }

      if (rateType == 'fat') {
        // Use customer-level ratePerFatPoint if available, else app-level setting
        final ratePerFat = _selectedCustomer != null
            ? _selectedCustomer!.ratePerFatPoint
            : appState.ratePerFatPoint;
        rate = fat * ratePerFat;
      }
    }

    setState(() {
      _computedRate = rate;
      _computedAmount = qty * rate;
    });
  }

  void _onKeypadTap(String value) {
    setState(() {
      if (_editingFat) {
        if (value == ".") {
          if (!_fatString.contains(".")) {
            _fatString += ".";
          }
        } else if (value == "clear") {
          _fatString = "";
        } else {
          _fatString += value;
        }
      } else {
        if (value == ".") {
          if (!_qtyString.contains(".")) {
            _qtyString += ".";
          }
        } else if (value == "clear") {
          _qtyString = "";
        } else {
          _qtyString += value;
        }
      }
      _calculateLiveAmount();
    });
  }

  void _onKeypadDelete() {
    setState(() {
      if (_editingFat) {
        if (_fatString.isNotEmpty) {
          _fatString = _fatString.substring(0, _fatString.length - 1);
        }
      } else {
        if (_qtyString.isNotEmpty) {
          _qtyString = _qtyString.substring(0, _qtyString.length - 1);
        }
      }
      _calculateLiveAmount();
    });
  }

  void _onKeypadClear() {
    setState(() {
      if (_editingFat) {
        _fatString = "";
      } else {
        _qtyString = "";
      }
      _calculateLiveAmount();
    });
  }

  void _incrementQty(double delta) {
    final current = double.tryParse(_qtyString) ?? 0.0;
    final updated = (current + delta).clamp(0.0, 999.0);
    setState(() {
      _qtyString = _fmtQty(updated);
      _calculateLiveAmount();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppCubit>().state;
    final isEdit = widget.editEntry != null;

    // tour तभी जब form दिख रहा हो — select-screen पर उसके target होते ही नहीं
    if ((isEdit || _selectedCustomer != null) && !_tourChecked) {
      _tourChecked = true;
      _checkAndShowTour();
    }

    return BlocListener<EntryCubit, EntryState>(
      listener: (context, state) {
        if (state is EntrySaved) {
          // Request permission and schedule daily reminders when user saves an entry
          final appState = context.read<AppCubit>().state;
          NotificationService.instance.requestPermissions().then((granted) {
            if (granted) {
              NotificationService.instance.scheduleDailyReminders(
                morningEnabled: appState.morningReminderEnabled,
                morningTime: appState.morningReminderTime,
                eveningEnabled: appState.eveningReminderEnabled,
                eveningTime: appState.eveningReminderTime,
              );
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.green),
          );
          // save होते ही सीधे दूध dashboard पर — कोई भटकाव नहीं
          MainShell.goToTab.value = 1;
          Navigator.pop(context);
        } else if (state is EntryDuplicateFound) {
          _handleDuplicate(context, state);
        } else if (state is EntryError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEdit
              ? AppLocalizations.get(context, 'edit')
              : _selectedCustomer == null
                  ? AppLocalizations.get(context, 'chooseCustomerTitle')
                  : AppLocalizations.get(context, 'todayEntry')),
        ),
        // नई एंट्री में पहला step: पूरी screen पर "किसका दूध?" —
        // ग्राहक चुनो या नया जोड़ो। form उसके बाद ही खुलता है।
        body: SafeArea(
          child: (!isEdit && _selectedCustomer == null)
              ? _buildCustomerSelectBody(context)
              : Column(
                  children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _buildCustomerPicker(context),
                        const SizedBox(height: 12),
                        _buildDateAndShiftRow(context),
                        const SizedBox(height: 12),
                        // बेचना/ख़रीदना सिर्फ़ "दोनों" वाले ग्राहक पर पूछो —
                        // ख़रीदार = बेचना, आपूर्तिकर्ता = ख़रीदना अपने-आप तय
                        if (isEdit ||
                            (_selectedCustomer?.partyType ?? 'both') ==
                                'both') ...[
                          _buildDirectionSelector(context),
                          const SizedBox(height: 12),
                        ],
                        _buildInputFieldsRow(context, appState),
                      ],
                    ),
                  ),
                  _buildCustomKeypad(context, appState),
                ],
              ),
        ),
      ),
    );
  }

  Widget _buildDateAndShiftRow(BuildContext context) {
    // तारीख़ का format: "24-07-2026 (सोम)" — दिन का नाम कोष्ठक में। DateFormat
    // को locale देते हैं ताकि "सोम/Mon/সোম" अपने-आप उसी भाषा में आए।
    final lang = Localizations.localeOf(context).languageCode;
    final formattedDate = DateFormat('dd-MM-yyyy (EEE)', lang).format(_selectedDate);

    return Card(
      key: _dateKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── तारीख़ (पूरी चौड़ाई) ──
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                );
                if (picked != null) {
                  setState(() {
                    _selectedDate = picked;
                  });
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        color: Theme.of(context).primaryColor, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        formattedDate,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 17),
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down_rounded,
                        color: Colors.grey),
                  ],
                ),
              ),
            ),
            const Divider(height: 12),
            // ── शिफ़्ट (सुबह / शाम) — बराबर दो बटन ──
            // पहले SegmentedButton था, हिंदी में label लंबे होने पर तारीख़ से
            // overlap होता था। अब अलग row + Expanded × 2 = हर भाषा में fit।
            Row(
              children: [
                Expanded(child: _shiftBtn(context, 'M',
                    icon: Icons.wb_sunny_rounded, label: 'morning')),
                const SizedBox(width: 8),
                Expanded(child: _shiftBtn(context, 'E',
                    icon: Icons.nights_stay_rounded, label: 'evening')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _shiftBtn(BuildContext context, String value,
      {required IconData icon, required String label}) {
    final selected = _shift == value;
    final teal = DairyTheme.primaryTeal;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => setState(() => _shift = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? teal : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: selected ? teal : Colors.grey.shade300, width: 1.4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: selected ? Colors.white : teal),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                AppLocalizations.get(context, label),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : Colors.grey.shade800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// दूध के साथ क्या कर रहे हैं — बेच रहे या ख़रीद रहे।
  ///
  /// अब यह किसान मोड में भी दिखता है (पहले सिर्फ़ doodhwala मोड में था —
  /// उपयोगकर्ताओं को इसीलिए नज़र नहीं आता था)। छोटा SegmentedButton हटाकर
  /// बड़े दो-बटन डाले हैं — किसान को साफ़ दिखे और आसानी से टैप कर सके।
  /// बेचना/ख़रीदना — सिर्फ़ दो बड़े बटन, ऊपर का शीर्षक हटाया (जगह बचे,
  /// बटन के label ख़ुद ही साफ़ हैं)।
  Widget _buildDirectionSelector(BuildContext context) {
    return Card(
      key: _directionKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Expanded(
                child: _dirBtn(context, 'sell',
                    icon: Icons.arrow_upward_rounded,
                    label: 'directionSell',
                    color: DairyTheme.primaryTeal)),
            const SizedBox(width: 8),
            Expanded(
                child: _dirBtn(context, 'buy',
                    icon: Icons.arrow_downward_rounded,
                    label: 'directionBuy',
                    color: Colors.orange.shade700)),
          ],
        ),
      ),
    );
  }

  Widget _dirBtn(BuildContext context, String value,
      {required IconData icon,
      required String label,
      required Color color}) {
    final selected = _direction == value;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        setState(() => _direction = value);
        _calculateLiveAmount();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? color : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: selected ? color : Colors.grey.shade300, width: 1.4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: selected ? Colors.white : color),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                AppLocalizations.get(context, label),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : Colors.grey.shade800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Form पर चुने हुए ग्राहक का card — "बदलें" दबाते ही वापस
  /// ग्राहक चुनने वाली screen पर।
  Widget _buildCustomerPicker(BuildContext context) {
    final c = _selectedCustomer;
    if (c == null) return const SizedBox.shrink(); // पुरानी बिना-ग्राहक entry (edit)
    final isEdit = widget.editEntry != null;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: DairyTheme.milkAccent.withValues(alpha: 0.12),
              child: Text(
                c.name.isNotEmpty ? c.name[0] : '?',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: DairyTheme.milkAccent),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w800)),
                  if (c.phone != null && c.phone!.isNotEmpty)
                    Text(c.phone!,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ),
            if (!isEdit)
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 38),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
                onPressed: () => setState(() {
                  _selectedCustomer = null;
                  _selectQuery = '';
                }),
                child: Text(AppLocalizations.get(context, 'changeBtn')),
              ),
          ],
        ),
      ),
    );
  }

  void _pickCustomer(Customer c) {
    setState(() {
      _selectedCustomer = c;
      _isCustomRate = false;
      _qtyString = c.defaultQtyL.toString();
      // ख़रीदार से = बेचना, आपूर्तिकर्ता से = ख़रीदना; "दोनों" पर form में पूछेंगे
      _direction = c.partyType == 'supplier' ? 'buy' : 'sell';
    });
    _calculateLiveAmount();
  }

  /// पहला step (पूरी screen): "किसका दूध?" — ग्राहकों की list, नीचे हमेशा
  /// "नया ग्राहक जोड़ें"। ग्राहक ही न हों तो सिर्फ़ जोड़ने का रास्ता।
  Widget _buildCustomerSelectBody(BuildContext context) {
    final customerState = context.watch<CustomerCubit>().state;
    final list = customerState is CustomerListLoaded
        ? customerState.customers
        : const <Customer>[];
    final shown = _selectQuery.isEmpty
        ? list
        : list
            .where((c) =>
                c.name.toLowerCase().contains(_selectQuery) ||
                (c.phone ?? '').contains(_selectQuery))
            .toList();

    return SafeArea(
      child: Column(
        children: [
          if (list.length > 6)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: TextField(
                decoration: InputDecoration(
                  hintText:
                      AppLocalizations.get(context, 'customer_search_hint'),
                  prefixIcon: const Icon(Icons.search_rounded),
                  isDense: true,
                ),
                onChanged: (v) =>
                    setState(() => _selectQuery = v.trim().toLowerCase()),
              ),
            ),
          Expanded(
            child: list.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.people_outline_rounded,
                              size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 14),
                          Text(
                            AppLocalizations.get(context, 'addCustomerFirst'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey[700]),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                    itemCount: shown.length,
                    itemBuilder: (_, i) {
                      final c = shown[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundColor:
                                DairyTheme.milkAccent.withValues(alpha: 0.12),
                            child: Text(
                              c.name.isNotEmpty ? c.name[0] : '?',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: DairyTheme.milkAccent),
                            ),
                          ),
                          title: Text(c.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w800, fontSize: 17)),
                          subtitle: Text(
                            '${c.defaultQtyL.toStringAsFixed(1)} ${AppLocalizations.get(context, 'litres')}'
                            '${(c.phone != null && c.phone!.isNotEmpty) ? ' · ${c.phone}' : ''}',
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey.shade600),
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded,
                              color: Colors.grey),
                          onTap: () => _pickCustomer(c),
                        ),
                      );
                    },
                  ),
          ),
          // हमेशा नीचे — नया ग्राहक जोड़ने का सीधा रास्ता
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(54)),
              icon: const Icon(Icons.person_add_rounded),
              label: Text(AppLocalizations.get(context, 'addCustomer')),
              onPressed: () => Navigator.pushNamed(context, '/customers'),
            ),
          ),
        ],
      ),
    );
  }

  /// 1.25 → "1.25", 1.50 → "1.5", 2.00 → "2" — फ़ालतू शून्य हटाकर
  String _fmtQty(double v) {
    var s = v.toStringAsFixed(2);
    if (s.contains('.')) {
      s = s.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
    }
    return s;
  }

  void _adjustQty(double delta) {
    final current = double.tryParse(_qtyString) ?? 0.0;
    final newVal = (current + delta).clamp(0.0, 999.0);
    setState(() {
      _qtyString = newVal == 0 ? '' : _fmtQty(newVal);
      _calculateLiveAmount();
    });
  }

  void _adjustFat(double delta) {
    final current = double.tryParse(_fatString) ?? 0.0;
    final newVal = (current + delta).clamp(0.0, 20.0);
    setState(() {
      _fatString = newVal == 0 ? '' : newVal.toStringAsFixed(2);
      _calculateLiveAmount();
    });
  }

  /// लीटर घटाने/बढ़ाने के दो-मंज़िला बटन: ±1 L (ऊपर) और ±250 ml (नीचे)।
  /// 1.250 ली जैसी मात्रा अब बिना keypad छुए आ जाती है।
  Widget _qtyStepColumn(BuildContext context, {required bool negative}) {
    final sign = negative ? '-' : '+';
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _qtyStepBtn('${sign}1 L', () => _adjustQty(negative ? -1.0 : 1.0),
            big: true),
        const SizedBox(height: 4),
        _qtyStepBtn('${sign}250 ml', () => _adjustQty(negative ? -0.25 : 0.25)),
      ],
    );
  }

  Widget _qtyStepBtn(String label, VoidCallback onTap, {bool big = false}) {
    return InkWell(
      borderRadius: BorderRadius.circular(9),
      onTap: onTap,
      child: Container(
        width: 66,
        padding: EdgeInsets.symmetric(vertical: big ? 9 : 6),
        decoration: BoxDecoration(
          color: DairyTheme.primaryTeal.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(9),
          border:
              Border.all(color: DairyTheme.primaryTeal.withValues(alpha: 0.5)),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: big ? 14 : 11.5,
            fontWeight: FontWeight.w800,
            color: DairyTheme.primaryTeal,
          ),
        ),
      ),
    );
  }

  Widget _buildInputFieldsRow(BuildContext context, AppState appState) {
    final isFat = appState.isFatBased || (_selectedCustomer != null && _selectedCustomer!.rateType == 'fat');

    // लीटर और फैट अब ऊपर-नीचे (पहले अग़ल-बग़ल थे) — ताकि ±1L/±250ml
    // बटनों के बाद भी लीटर का डिब्बा बड़ा और साफ़ रहे।
    return Column(
      children: [
        Row(
          children: [
            _qtyStepColumn(context, negative: true),
            const SizedBox(width: 6),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _editingFat = false;
                  });
                },
                child: Container(
                  key: _qtyKey,
                  padding:
                      const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                  decoration: BoxDecoration(
                    color: !_editingFat
                        ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                        : Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: !_editingFat
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(AppLocalizations.get(context, 'litres'),
                          style: const TextStyle(fontSize: 13)),
                      const SizedBox(height: 2),
                      Text(
                        _qtyString.isEmpty ? "0" : _qtyString,
                        style: const TextStyle(
                            fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            _qtyStepColumn(context, negative: false),
          ],
        ),
        if (isFat) ...[
          const SizedBox(height: 8),
          SizedBox(
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: Colors.orange),
                  onPressed: () => _adjustFat(-0.05),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _editingFat = true;
                      });
                    },
                    child: Container(
                      key: _fatKey,
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                      decoration: BoxDecoration(
                        color: _editingFat ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _editingFat ? Theme.of(context).primaryColor : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(AppLocalizations.get(context, 'fat'), style: const TextStyle(fontSize: 14)),
                          const SizedBox(height: 4),
                          Text(
                            _fatString.isEmpty ? "0.0" : _fatString,
                            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: Colors.orange),
                  onPressed: () => _adjustFat(0.05),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// कीपैड के ठीक ऊपर हमेशा दिखने वाली पतली पट्टी — रेट (बदलने के icon के
  /// साथ) और कुल राशि। पहले यह अलग card में ListView के अंदर था; छोटे फ़ोन
  /// (जैसे Vivo Y21) पर कीपैड के पीछे छिप जाता था और कुल राशि दिखती ही नहीं थी।
  Widget _buildPinnedTotalBar(BuildContext context) {
    final nf = NumberFormat('#,##,##0', 'en_IN');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Text(
            '₹${_computedRate.toStringAsFixed(1)}/${AppLocalizations.get(context, 'litres')}',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: _isCustomRate ? Colors.orange[800] : Colors.grey[800],
            ),
          ),
          IconButton(
            key: _rateKey,
            icon: Icon(Icons.edit_rounded,
                color: Theme.of(context).primaryColor, size: 18),
            padding: const EdgeInsets.all(6),
            constraints: const BoxConstraints(),
            onPressed: () => _showRateEditDialog(context),
            tooltip: 'रेट बदलें',
          ),
          if (_isCustomRate)
            IconButton(
              icon: const Icon(Icons.settings_backup_restore_rounded,
                  color: Colors.grey, size: 18),
              padding: const EdgeInsets.all(6),
              constraints: const BoxConstraints(),
              onPressed: () {
                setState(() {
                  _isCustomRate = false;
                  _customRate = 0.0;
                  _calculateLiveAmount();
                });
              },
              tooltip: 'डिफ़ॉल्ट रेट',
            ),
          const Spacer(),
          Text(
            '${AppLocalizations.get(context, 'amount')}: ',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          Text(
            '₹${nf.format(_computedAmount)}',
            style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.w800,
                fontSize: 19),
          ),
        ],
      ),
    );
  }

  void _showRateEditDialog(BuildContext context) {
    final controller = TextEditingController(text: _computedRate.toStringAsFixed(2));
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(AppLocalizations.get(context, 'entry_change_rate_title')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('आज के लिए एक कस्टम रेट दर्ज करें (₹/लीटर):'),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  prefixText: '₹ ',
                  hintText: '60.00',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('रद्द करें'),
            ),
            ElevatedButton(
              onPressed: () {
                final newRate = double.tryParse(controller.text.trim());
                if (newRate != null && newRate > 0) {
                  setState(() {
                    _isCustomRate = true;
                    _customRate = newRate;
                    _calculateLiveAmount();
                  });
                }
                Navigator.pop(ctx);
              },
              child: const Text('लागू करें'),
            ),
          ],
        );
      },
    );
  }

  /// निचला हिस्सा — जान-बूझकर छोटा रखा है ताकि छोटे फ़ोन पर भी ऊपर की
  /// चीज़ें (ग्राहक, लीटर, तारीख़) दिखती रहें:
  ///  • +0.5/+1 shortcut बटन
  ///  • रेट/कुल राशि की pinned पट्टी (हमेशा दिखे)
  ///  • अंक keypad + OK
  /// पहले यहाँ "कीपैड सेटिंग / बड़ा कीपैड मोड" की एक और पट्टी थी — हटा दी,
  /// clutter कम हुआ और जगह बची।
  Widget _buildCustomKeypad(BuildContext context, AppState appState) {
    return SafeArea(
      top: false,
      child: Container(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF141F15)
            : Colors.grey.shade200,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!_editingFat)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildIncrementBtn("+0.5"),
                  _buildIncrementBtn("+1.0"),
                  _buildIncrementBtn("+2.0"),
                  _buildIncrementBtn("+5.0"),
                ],
              ),
            const SizedBox(height: 4),
            _buildPinnedTotalBar(context),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Row(children: [_buildKey("1"), _buildKey("2"), _buildKey("3")]),
                      Row(children: [_buildKey("4"), _buildKey("5"), _buildKey("6")]),
                      Row(children: [_buildKey("7"), _buildKey("8"), _buildKey("9")]),
                      Row(children: [
                        _buildKey("."),
                        _buildKey("0"),
                        _buildKey("clear", icon: Icons.backspace_rounded),
                      ]),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  key: _okKey,
                  width: 84,
                  height: 216,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _submitEntry,
                    child: const Text('OK', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildIncrementBtn(String label) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).cardColor,
        foregroundColor: Theme.of(context).primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      onPressed: () {
        final val = double.tryParse(label.replaceAll("+", "")) ?? 0.0;
        _incrementQty(val);
      },
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
    );
  }

  Widget _buildKey(String value, {IconData? icon}) {
    // "clear" key = backspace icon: एक tap → आख़िरी अंक मिटे,
    // देर तक दबाओ → पूरा साफ़। (पहले tap से ही पूरा मिट जाता था —
    // icon backspace का और काम clear का, भ्रम होता था।)
    final isBackspace = value == "clear";
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: SizedBox(
          height: 46,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              backgroundColor: Theme.of(context).cardColor,
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed:
                isBackspace ? _onKeypadDelete : () => _onKeypadTap(value),
            onLongPress: isBackspace ? _onKeypadClear : null,
            child: icon != null
                ? Icon(icon, color: Colors.red[800])
                : Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  void _submitEntry() {
    final qty = double.tryParse(_qtyString) ?? 0.0;
    final fat = double.tryParse(_fatString);

    if (qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.get(context, 'entry_valid_qty_error')), backgroundColor: Colors.orange),
      );
      return;
    }

    // form ग्राहक चुने बिना खुलता ही नहीं — फिर भी सुरक्षा जाल
    if (widget.editEntry == null && _selectedCustomer == null) {
      return;
    }

    final formattedDate = DateFormat('dd-MM-yyyy').format(_selectedDate);

    if (widget.editEntry != null) {
      final updated = widget.editEntry!.copyWith(
        date: formattedDate,
        shift: _shift,
        qtyL: qty,
        fatPct: fat,
        amount: _computedAmount,
        direction: _direction,
      );
      context.read<EntryCubit>().updateEntry(updated);
    } else {
      context.read<EntryCubit>().saveEntry(
            customerId: _selectedCustomer?.id,
            date: formattedDate,
            shift: _shift,
            qtyL: qty,
            fatPct: fat,
            amount: _computedAmount,
            direction: _direction,
          );
    }
  }

  void _handleDuplicate(BuildContext context, EntryDuplicateFound state) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(AppLocalizations.get(context, 'duplicateTitle')),
          content: Text(AppLocalizations.get(context, 'duplicateDesc')),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.read<EntryCubit>().replaceEntry(state.existingEntry, state.newEntry);
              },
              child: Text(AppLocalizations.get(context, 'replace')),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.read<EntryCubit>().addAlongside(state.newEntry);
              },
              child: Text(AppLocalizations.get(context, 'addNew')),
            ),
          ],
        );
      },
    );
  }
}
