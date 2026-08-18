import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../blocs/entry_cubit.dart';
import '../../blocs/customer_cubit.dart';
import '../../l10n/app_localizations.dart';
import '../../db/db_change_bus.dart';
import '../../db/models/milk_entry.dart';
import '../../db/models/customer.dart';
import '../../db/dao/entry_dao.dart';
import 'theme/dairy_theme.dart';
import 'weather/weather_common.dart' show fullDate, kMonthsHi, kMonthsShortEn;

/// दूध tab की मुख्य screen — dashboard शैली।
///
/// डिज़ाइन (2026-07 सुधार):
///  • ऊपर teal gradient header — आज की तारीख़ + सुबह/शाम की एंट्री का हाल
///  • महीने का हिसाब 2×2 बड़े tiles में
///  • बीच में बड़ा "आज की एंट्री" बटन — सबसे ज़रूरी काम सबसे आगे
///  • फिर ग्राहक (बाकी राशि के साथ) और हाल की एंट्रियाँ
///
/// Data अपने-आप ताज़ा रहता है — [dbChangeBus] हर DB बदलाव पर बजता है और
/// यह screen तुरंत reload कर लेती है। खींचकर refresh करने की ज़रूरत नहीं।
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final EntryDao _entryDao = EntryDao();

  List<MilkEntry> _todayEntries = [];

  // आख़िरी बार load हुआ data — EntryCubit बीच में EntrySaved/Loading emit करे
  // तो भी list ख़ाली होकर न झपके।
  List<MilkEntry> _recentEntries = [];
  Map<String, double> _monthlyTotals = const {};

  /// महीने का हिसाब खुला है या सिर्फ़ एक पंक्ति में
  bool _monthOpen = false;

  @override
  void initState() {
    super.initState();
    _reloadAll();
    dbChangeBus.addListener(_reloadAll);
  }

  @override
  void dispose() {
    dbChangeBus.removeListener(_reloadAll);
    super.dispose();
  }

  /// सारा data फिर से लाओ — DB में कहीं भी कुछ बदले तो यही चलता है।
  void _reloadAll() {
    if (!mounted) return;
    context.read<EntryCubit>().loadHomeData();
    context.read<CustomerCubit>().loadCustomers();
    _loadTodayEntries();
  }

  Future<void> _loadTodayEntries() async {
    final today = DateFormat('dd-MM-yyyy').format(DateTime.now());
    final entries = await _entryDao.getEntriesByDate(today);
    if (mounted) {
      setState(() => _todayEntries = entries);
    }
  }

  String _t(String k) => AppLocalizations.get(context, k);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<EntryCubit, EntryState>(
        listener: (context, state) {
          if (state is EntryListLoaded) {
            setState(() {
              _recentEntries = state.entries;
              _monthlyTotals = state.monthlyTotals;
            });
          }
        },
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => _reloadAll(),
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: _buildHeader(context)),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          // ── सबसे ज़रूरी काम सबसे ऊपर ──
                          // पहले यह महीने के हिसाब के नीचे था और scroll किए
                          // बिना दिखता ही नहीं था। किसान रोज़ यही दबाता है।
                          _buildBigEntryButton(context),
                          const SizedBox(height: 14),

                          // ── महीने का हिसाब — एक ही पंक्ति ──
                          _buildMonthlySummary(context),
                          const SizedBox(height: 14),

                          // ── जिनसे पैसा लेना है ──
                          _buildCustomerSection(context),
                          const SizedBox(height: 10),

                          // ── हाल की एंट्रियाँ — सिर्फ़ आख़िरी कुछ ──
                          if (_recentEntries.isEmpty)
                            _buildEmptyState(context)
                          else
                            _buildRecentEntriesList(
                                context, _recentEntries.take(4).toList()),
                          if (_recentEntries.length > 4)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                icon: const Icon(Icons.list_alt_rounded, size: 18),
                                label: Text(_t('seeAllEntries')),
                                onPressed: () =>
                                    Navigator.pushNamed(context, '/report'),
                              ),
                            ),

                          SizedBox(
                              height:
                                  MediaQuery.of(context).padding.bottom + 8),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── Header ─────────────────────────

  Widget _buildHeader(BuildContext context) {
    final isHi = AppLocalizations.isHindiLike(context);
    final dateStr = fullDate(DateTime.now(), isHi);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 12, 18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [DairyTheme.milkAccent, Color(0xFF00695C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(26)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('🥛 ${_t('milkDashTitle')}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(dateStr,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 13)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.people_alt_rounded,
                    color: Colors.white, size: 26),
                tooltip: _t('customers'),
                onPressed: () => Navigator.pushNamed(context, '/customers'),
              ),
              IconButton(
                icon: const Icon(Icons.analytics_outlined,
                    color: Colors.white, size: 26),
                tooltip: _t('monthlyReport'),
                onPressed: () => Navigator.pushNamed(context, '/report'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // आज की सुबह/शाम — एक नज़र में
          Row(
            children: [
              Expanded(child: _todayShiftChip(context, 'M')),
              const SizedBox(width: 10),
              Expanded(child: _todayShiftChip(context, 'E')),
            ],
          ),
        ],
      ),
    );
  }

  /// header के अंदर सुबह/शाम की स्थिति — हुई हो तो लीटर+₹, नहीं तो "बाकी"।
  Widget _todayShiftChip(BuildContext context, String shift) {
    final entries = _todayEntries.where((e) => e.shift == shift).toList();
    final done = entries.isNotEmpty;
    double qty = 0, amount = 0;
    for (final e in entries) {
      qty += e.qtyL;
      amount += e.amount;
    }
    final nf = NumberFormat('#,##,##0', 'en_IN');
    final label = shift == 'M' ? _t('morning') : _t('evening');
    final emoji = shift == 'M' ? '🌅' : '🌙';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12)),
                Text(
                  done
                      ? '${qty.toStringAsFixed(1)} ${_t('litres')} · ₹${nf.format(amount)}'
                      : _t('home_today_shift_pending'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          Icon(
            done ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            color: done ? const Color(0xFF9CFF9C) : Colors.white70,
            size: 20,
          ),
        ],
      ),
    );
  }

  // ───────────────────── Monthly summary ─────────────────────

  /// महीने का हिसाब — **एक पंक्ति**: सिर्फ़ कमाई।
  ///
  /// पहले 4 बड़े खाने (2×2) आधी स्क्रीन खा जाते थे, जबकि किसान को रोज़ सिर्फ़
  /// "इस महीने कितना कमाया" देखना होता है। बाक़ी तीन आँकड़े ⌄ दबाने पर खुलते
  /// हैं — जानकारी कुछ भी कम नहीं हुई, बस सामने कम है।
  Widget _buildMonthlySummary(BuildContext context) {
    final nf = NumberFormat('#,##,##0', 'en_IN');
    final totals = _monthlyTotals;
    final litres = totals['totalLitres'] ?? 0.0;
    final totalSell = totals['totalSell'] ?? totals['totalAmount'] ?? 0.0;
    final totalBuy = totals['totalBuy'] ?? 0.0;
    final netAmount = totals['netAmount'] ?? (totalSell - totalBuy);

    final isHi = AppLocalizations.isHindiLike(context);
    final m = DateTime.now().month;
    final monthName = isHi ? kMonthsHi[m] : kMonthsShortEn[m];

    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => setState(() => _monthOpen = !_monthOpen),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_wallet_rounded,
                      color: DairyTheme.milkAccent, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '$monthName ${DateTime.now().year}',
                      style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                          color: DairyTheme.textLight),
                    ),
                  ),
                  Text(
                    '₹${nf.format(totalSell)}',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.green.shade800),
                  ),
                  Icon(
                    _monthOpen
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
          // खुलने पर बाक़ी तीन आँकड़े
          if (_monthOpen)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                children: [
                  const Divider(height: 8),
                  Row(
                    children: [
                      _summaryTile(
                        icon: Icons.local_drink_rounded,
                        color: DairyTheme.milkAccent,
                        label: _t('totalLitres'),
                        value: '${litres.toStringAsFixed(1)} ${_t('litres')}',
                      ),
                      const SizedBox(width: 10),
                      _summaryTile(
                        icon: Icons.arrow_downward_rounded,
                        color: Colors.orange.shade800,
                        label: _t('totalBuyLabel'),
                        value: '₹${nf.format(totalBuy)}',
                      ),
                      const SizedBox(width: 10),
                      _summaryTile(
                        icon: Icons.account_balance_rounded,
                        color: netAmount >= 0
                            ? Colors.purple.shade800
                            : Colors.red.shade800,
                        label: _t('netBalanceLabel'),
                        value: '₹${nf.format(netAmount)}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _summaryTile({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.18)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: color),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    label,
                    style: const TextStyle(
                        fontSize: 11, color: DairyTheme.textLight),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────── Entry CTA ─────────────────────

  /// पन्ने का मुख्य बटन — अब सबसे ऊपर।
  ///
  /// आज कुछ बाकी हो तो बड़ा और चमकीला; दोनों वक़्त की एंट्री हो चुकी हो तो
  /// छोटा होकर "आज का काम पूरा" बन जाता है — किसान को एक नज़र में पता चल
  /// जाता है कि आज कुछ करना बचा है या नहीं।
  Widget _buildBigEntryButton(BuildContext context) {
    final done = _todayEntries.any((e) => e.shift == 'M') &&
        _todayEntries.any((e) => e.shift == 'E');

    if (done) {
      return InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.pushNamed(context, '/entry'),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.green.shade300),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle_rounded,
                  color: Colors.green.shade700, size: 26),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _t('todayDone'),
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.green.shade900),
                ),
              ),
              Icon(Icons.add_circle_outline_rounded,
                  color: Colors.green.shade700),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 76,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          elevation: 3,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18)),
        ),
        icon: const Icon(Icons.add_circle, size: 32, color: Colors.white),
        label: Text(
          _t('entryPendingCta'),
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
        ),
        onPressed: () => Navigator.pushNamed(context, '/entry'),
      ),
    );
  }

  // ───────────────────── Customers ─────────────────────

  Widget _buildCustomerSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                _t('moneyToCollect'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: DairyTheme.textDark),
              ),
            ),
            TextButton.icon(
              icon: const Icon(Icons.people_alt_rounded, size: 18),
              label: Text(_t('home_see_all')),
              onPressed: () => Navigator.pushNamed(context, '/customers'),
            ),
          ],
        ),
        BlocBuilder<CustomerCubit, CustomerState>(
          builder: (context, state) {
            if (state is! CustomerListLoaded) {
              return const SizedBox.shrink();
            }
            final list = state.customers;
            if (list.isEmpty) {
              return Card(
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => Navigator.pushNamed(context, '/customers'),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Row(
                      children: [
                        const Icon(Icons.person_add_rounded,
                            color: DairyTheme.primaryTeal, size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _t('addFirstCustomer'),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded,
                            color: Colors.grey),
                      ],
                    ),
                  ),
                ),
              );
            }

            // सिर्फ़ वही ग्राहक जिनसे पैसा लेना बाकी है — बराबर हिसाब
            // वालों को यहाँ दिखाने का कोई काम नहीं (सूची छोटी और मतलब साफ़)।
            final pending = list
                .where((c) => (state.dues[c.id] ?? 0.0) > 0.5)
                .toList()
              ..sort((a, b) =>
                  (state.dues[b.id] ?? 0).compareTo(state.dues[a.id] ?? 0));

            if (pending.isEmpty) {
              return Card(
                margin: EdgeInsets.zero,
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_rounded,
                          color: Colors.green.shade700, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _t('allSettled'),
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14.5,
                              color: Colors.green.shade900),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final nf = NumberFormat('#,##,##0', 'en_IN');
            return Column(
              children: pending
                  .take(5)
                  .map((c) =>
                      _customerRow(context, c, state.dues[c.id] ?? 0.0, nf))
                  .toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _customerRow(
      BuildContext context, Customer customer, double due, NumberFormat nf) {
    final isDue = due > 0;
    final isAdv = due < 0;
    final dueColor = isDue
        ? Colors.red[800]
        : isAdv
            ? Colors.green[800]
            : Colors.grey[600];
    final dueText = isDue
        ? '₹${nf.format(due.abs())} ${_t('due')}'
        : isAdv
            ? '₹${nf.format(due.abs())} ${_t('advance')}'
            : '₹0';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 3),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        leading: CircleAvatar(
          backgroundColor: DairyTheme.milkAccent.withValues(alpha: 0.12),
          child: Text(
            customer.name.isNotEmpty ? customer.name[0] : '?',
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: DairyTheme.milkAccent),
          ),
        ),
        title: Text(customer.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Text(
          '${customer.defaultQtyL.toStringAsFixed(1)} ${_t('litres')}',
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: dueColor?.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                dueText,
                style: TextStyle(
                    color: dueColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
              ),
            ),
            if (customer.phone != null && customer.phone!.isNotEmpty) ...[
              const SizedBox(width: 4),
              IconButton(
                icon: Icon(Icons.call_rounded,
                    color: Colors.green[700], size: 20),
                padding: EdgeInsets.zero,
                constraints:
                    const BoxConstraints(minWidth: 36, minHeight: 36),
                onPressed: () async {
                  // canLaunchUrl नहीं — Android 11+ पर भरोसेमंद नहीं
                  try {
                    await launchUrl(Uri.parse('tel:${customer.phone}'),
                        mode: LaunchMode.externalApplication);
                  } catch (_) {}
                },
              ),
            ],
          ],
        ),
        onTap: () {
          Navigator.pushNamed(context, '/customer_detail',
              arguments: customer);
        },
      ),
    );
  }

  // ───────────────────── Recent entries ─────────────────────

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(Icons.history_toggle_off_rounded,
                size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              _t('noEntries'),
              style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentEntriesList(
      BuildContext context, List<MilkEntry> entries) {
    final nf = NumberFormat('#,##,##0', 'en_IN');

    // ग्राहक के नाम CustomerCubit से — हर row पर अलग DB-call नहीं।
    final customerState = context.watch<CustomerCubit>().state;
    final names = <int, String>{};
    if (customerState is CustomerListLoaded) {
      for (final c in customerState.customers) {
        if (c.id != null) names[c.id!] = c.name;
      }
    }

    // तारीख़-वार समूह — timeline जैसा
    final grouped = <String, List<MilkEntry>>{};
    for (final entry in entries) {
      grouped.putIfAbsent(entry.date, () => []).add(entry);
    }

    final today = DateFormat('dd-MM-yyyy').format(DateTime.now());
    final yesterday = DateFormat('dd-MM-yyyy')
        .format(DateTime.now().subtract(const Duration(days: 1)));

    return Column(
      children: grouped.entries.map((group) {
        final date = group.key;
        final dateEntries = group.value;
        final dateLabel = date == today
            ? _t('home_today_label')
            : date == yesterday
                ? _t('home_today_yesterday')
                : '📅 $date';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, top: 8, bottom: 4),
              child: Text(dateLabel,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600])),
            ),
            ...dateEntries.map((entry) {
              final shift = entry.shift == 'M'
                  ? _t('morning')
                  : _t('evening');
              final shiftIcon = entry.shift == 'M'
                  ? Icons.wb_sunny_rounded
                  : Icons.nights_stay_rounded;
              final shiftColor =
                  entry.shift == 'M' ? Colors.orange[800] : Colors.indigo[800];
              final name = entry.customerId != null
                  ? (names[entry.customerId] ?? _t('home_farmer_default'))
                  : _t('home_farmer_default');

              return Dismissible(
                key: ValueKey(entry.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.delete_forever_rounded,
                      color: Colors.red, size: 28),
                ),
                confirmDismiss: (direction) async {
                  return await _confirmDeleteInline(context, entry);
                },
                child: Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: shiftColor?.withValues(alpha: 0.1),
                      child: Icon(shiftIcon, color: shiftColor),
                    ),
                    title: Text(
                      name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Text(
                      shift,
                      style:
                          TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${entry.qtyL.toStringAsFixed(1)} ${_t('litres')}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          '₹${nf.format(entry.amount)}',
                          style: const TextStyle(
                            color: DairyTheme.milkAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    onLongPress: () => _showEntryActions(context, entry),
                  ),
                ),
              );
            }),
          ],
        );
      }).toList(),
    );
  }

  Future<bool?> _confirmDeleteInline(
      BuildContext context, MilkEntry entry) async {
    return showDialog<bool>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(_t('warning')),
          content:
              const Text('क्या आप इस एंट्री को हमेशा के लिए हटाना चाहते हैं?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(_t('no')),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
              onPressed: () {
                if (entry.id != null) {
                  context.read<EntryCubit>().deleteEntry(entry.id!);
                }
                Navigator.pop(ctx, true);
              },
              child: Text(_t('yes')),
            ),
          ],
        );
      },
    );
  }

  void _showEntryActions(BuildContext context, MilkEntry entry) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.edit_rounded, color: Colors.blue),
                title: Text(_t('edit')),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(context, '/entry', arguments: entry);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever_rounded,
                    color: Colors.red),
                title: Text(_t('delete')),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmDelete(context, entry);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, MilkEntry entry) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(_t('warning')),
          content:
              const Text('क्या आप इस एंट्री को हमेशा के लिए हटाना चाहते हैं?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(_t('no')),
            ),
            ElevatedButton(
              onPressed: () {
                if (entry.id != null) {
                  context.read<EntryCubit>().deleteEntry(entry.id!);
                }
                Navigator.pop(ctx);
              },
              child: Text(_t('yes')),
            ),
          ],
        );
      },
    );
  }
}
