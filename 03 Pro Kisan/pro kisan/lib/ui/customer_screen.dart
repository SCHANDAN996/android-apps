import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../blocs/customer_cubit.dart';
import '../db/models/customer.dart';
import '../l10n/app_localizations.dart';
import 'theme/dairy_theme.dart';
import 'widgets/pro_tour.dart';
import '../db/dao/settings_dao.dart';

// canLaunchUrl नहीं — Android 11+ पर वह false लौटाकर बटन को चुप कर देता है
Future<void> _launchPhone(String phone) async {
  try {
    await launchUrl(Uri.parse('tel:$phone'),
        mode: LaunchMode.externalApplication);
  } catch (_) {}
}

Future<void> _launchWhatsApp(String phone) async {
  final cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');
  final number = cleaned.length == 10 ? '91$cleaned' : cleaned;
  try {
    await launchUrl(Uri.parse('https://wa.me/$number'),
        mode: LaunchMode.externalApplication);
  } catch (_) {}
}

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key});

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  String _searchQuery = '';

  final GlobalKey _searchKey = GlobalKey();
  final GlobalKey _firstCustomerKey = GlobalKey();
  final GlobalKey _fabKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    context.read<CustomerCubit>().loadCustomers();
    _checkAndShowTour();
  }

  Future<void> _checkAndShowTour() async {
    final settings = SettingsDao();
    final hasSeen = await settings.hasSeenCustomerTour();
    if (!hasSeen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _showTutorial();
          }
        });
      });
    }
  }

  /// ग्राहक वाले पन्ने का रास्ता — घेरा अब चौकोर, आगे बढ़ने का बटन साफ़।
  /// सब कुछ `ProTour` में तय है, इसलिए हर screen एक जैसी दिखती है।
  void _showTutorial() {
    ProTour.dikhao(
      context,
      steps: [
        ProTourStep(
          key: _searchKey,
          title: _t('tour_cust_search_title'),
          desc: _t('tour_cust_search_desc'),
        ),
        ProTourStep(
          key: _firstCustomerKey,
          title: _t('tour_cust_card_title'),
          desc: _t('tour_cust_card_desc'),
        ),
        ProTourStep(
          key: _fabKey,
          title: _t('tour_cust_fab_title'),
          desc: _t('tour_cust_fab_desc'),
        ),
      ],
      onKhatam: () => SettingsDao().setSeenCustomerTour(),
    );
  }

  String _t(String key) => AppLocalizations.get(context, key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_t('customers')),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: TextField(
                key: _searchKey,
                decoration: InputDecoration(
                  hintText: _t('customer_search_hint'),
                  prefixIcon: const Icon(Icons.search_rounded),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
              ),
            ),
            Expanded(
              child: BlocBuilder<CustomerCubit, CustomerState>(
                builder: (context, state) {
                  if (state is CustomerLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is CustomerListLoaded) {
                    var list = state.customers;

                    if (_searchQuery.isNotEmpty) {
                      list = list.where((c) {
                        return c.name.toLowerCase().contains(_searchQuery) ||
                            (c.phone ?? '').contains(_searchQuery);
                      }).toList();
                    }

                    if (list.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people_outline_rounded, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 12),
                            Text(
                              _searchQuery.isNotEmpty ? _t('customer_no_customer_found') : _t('customer_no_customers'),
                              style: const TextStyle(fontSize: 18, color: Colors.grey),
                            ),
                            if (_searchQuery.isEmpty) ...[
                              const SizedBox(height: 8),
                              Text(_t('customer_add_from_here'),
                                  style: const TextStyle(fontSize: 14, color: Colors.grey)),
                            ],
                          ],
                        ),
                      );
                    }

                    final nf = NumberFormat('#,##,##0', 'en_IN');

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 80),
                      itemCount: list.length,
                      itemBuilder: (context, idx) {
                        final customer = list[idx];
                        final due = state.dues[customer.id] ?? 0.0;
                        if (idx == 0) {
                          return Container(
                            key: _firstCustomerKey,
                            child: _buildCustomerCard(context, customer, due, nf),
                          );
                        }
                        return _buildCustomerCard(context, customer, due, nf);
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: _fabKey,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: Text(_t('addCustomer'),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () => _showAddEditSheet(context),
      ),
    );
  }

  Widget _buildCustomerCard(
    BuildContext context,
    Customer customer,
    double due,
    NumberFormat nf,
  ) {
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
            : _t('customer_balance_equal');
    final hasPhone = customer.phone != null && customer.phone!.isNotEmpty;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/customer_detail',
            arguments: customer,
          ).then((_) {
            context.read<CustomerCubit>().loadCustomers();
          });
        },
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: DairyTheme.primaryTeal.withOpacity(0.12),
                    child: Text(
                      customer.name.isNotEmpty ? customer.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: DairyTheme.primaryTeal,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                customer.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 6),
                            _partyBadge(customer.partyType),
                          ],
                        ),
                        if (hasPhone)
                          Text(
                            customer.phone!,
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          ),
                        if (customer.address != null && customer.address!.isNotEmpty)
                          Text(
                            '📍 ${customer.address}',
                            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: dueColor?.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      dueText,
                      style: TextStyle(
                        color: dueColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.local_drink_rounded, size: 16, color: DairyTheme.milkAccent),
                    const SizedBox(width: 6),
                    Text(
                      '${_t('defaultQtyLabel')}: ${customer.defaultQtyL.toStringAsFixed(1)} ${_t('litres')}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.currency_rupee_rounded, size: 14, color: Colors.grey[600]),
                    Text(
                      customer.rateType == 'flat'
                          ? '₹${customer.flatRate.toStringAsFixed(0)}/${_t('litres')} (${_t('flat')})'
                          : '₹${customer.ratePerFatPoint.toStringAsFixed(1)}/${_t('fat')} (${_t('fatBased')})',
                      style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  if (hasPhone) ...[
                    _actionChip(
                      icon: Icons.call_rounded,
                      label: _t('customer_call_action'),
                      color: Colors.green[700]!,
                      onTap: () => _makeCall(customer.phone!),
                    ),
                    const SizedBox(width: 8),
                    _actionChip(
                      icon: Icons.message_rounded,
                      label: _t('customer_whatsapp_action'),
                      color: const Color(0xFF25D366),
                      onTap: () => _openWhatsApp(customer.phone!),
                    ),
                    const SizedBox(width: 8),
                  ],
                  _actionChip(
                    icon: Icons.edit_note_rounded,
                    label: _t('customer_edit_action'),
                    color: Colors.blue[700]!,
                    onTap: () => _showAddEditSheet(context, customer: customer),
                  ),
                  const Spacer(),
                  _actionChip(
                    icon: Icons.delete_outline_rounded,
                    label: _t('customer_delete_action'),
                    color: Colors.red[700]!,
                    onTap: () => _confirmDeactivate(context, customer),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionChip({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _partyBadge(String partyType) {
    Color bg;
    Color fg;
    String labelKey;
    switch (partyType) {
      case 'supplier':
        bg = Colors.green.shade100;
        fg = Colors.green.shade800;
        labelKey = 'partyTypeSupplier';
        break;
      case 'both':
        bg = Colors.purple.shade100;
        fg = Colors.purple.shade800;
        labelKey = 'partyTypeBoth';
        break;
      default:
        bg = Colors.blue.shade100;
        fg = Colors.blue.shade800;
        labelKey = 'partyTypeBuyer';
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        _t(labelKey),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: fg),
      ),
    );
  }

  void _makeCall(String phone) async {
    try {
      _launchPhone(phone);
    } catch (_) {}
  }

  void _openWhatsApp(String phone) async {
    try {
      _launchWhatsApp(phone);
    } catch (_) {}
  }

  void _showAddEditSheet(BuildContext context, {Customer? customer}) {
    final nameController = TextEditingController(text: customer?.name ?? '');
    final phoneController = TextEditingController(text: customer?.phone ?? '');
    final addressController = TextEditingController(text: customer?.address ?? '');
    final flatRateController = TextEditingController(text: customer?.flatRate.toString() ?? '60');
    final fatRateController = TextEditingController(text: customer?.ratePerFatPoint.toString() ?? '6.8');
    final qtyController = TextEditingController(text: customer?.defaultQtyL.toString() ?? '1.0');
    String rateType = customer?.rateType ?? 'flat';
    String partyType = customer?.partyType ?? 'buyer';

    final isEdit = customer != null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateSheet) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: SafeArea(
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.85,
                  ),
                  child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 48,
                      height: 5,
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Row(
                        children: [
                          Icon(
                            isEdit ? Icons.edit_rounded : Icons.person_add_rounded,
                            color: DairyTheme.primaryTeal,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            isEdit ? _t('customer_edit_title') : _t('addCustomer'),
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // 📱 फ़ोन की कॉन्टैक्ट-बुक से नाम+नंबर सीधे भरो —
                            // हाथ से टाइप करने की ज़रूरत नहीं।
                            if (!isEdit) ...[
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  minimumSize: const Size.fromHeight(46),
                                ),
                                icon: const Icon(Icons.contact_phone_rounded, size: 20),
                                label: Text(_t('pickFromContacts')),
                                onPressed: () => _pickFromContacts(
                                    ctx, nameController, phoneController),
                              ),
                              const SizedBox(height: 16),
                            ],
                            _buildFieldLabel(_t('customer_name_label')),
                            const SizedBox(height: 6),
                            TextField(
                              controller: nameController,
                              decoration: InputDecoration(hintText: _t('customerName')),
                              textCapitalization: TextCapitalization.words,
                            ),
                            const SizedBox(height: 16),
                            _buildFieldLabel(_t('customer_phone_label')),
                            const SizedBox(height: 6),
                            TextField(
                              controller: phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(hintText: '9876543210'),
                            ),
                            const SizedBox(height: 16),
                            _buildFieldLabel(_t('customer_address_label')),
                            const SizedBox(height: 6),
                            TextField(
                              controller: addressController,
                              decoration: InputDecoration(hintText: _t('customer_address_label')),
                            ),
                            const SizedBox(height: 16),
                            _buildFieldLabel(_t('customer_default_qty_label')),
                            const SizedBox(height: 6),
                            TextField(
                              controller: qtyController,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(hintText: '5.0'),
                            ),
                             const SizedBox(height: 16),
                             _buildFieldLabel(_t('partyTypeLabel')),
                             const SizedBox(height: 8),
                             SegmentedButton<String>(
                               segments: [
                                 ButtonSegment(
                                   value: 'buyer',
                                   label: Text(_t('partyTypeBuyer')),
                                   icon: const Icon(Icons.shopping_cart_rounded, size: 16),
                                 ),
                                 ButtonSegment(
                                   value: 'supplier',
                                   label: Text(_t('partyTypeSupplier')),
                                   icon: const Icon(Icons.agriculture_rounded, size: 16),
                                 ),
                                 ButtonSegment(
                                   value: 'both',
                                   label: Text(_t('partyTypeBoth')),
                                   icon: const Icon(Icons.sync_alt_rounded, size: 16),
                                 ),
                               ],
                               selected: {partyType},
                               onSelectionChanged: (val) => setStateSheet(() => partyType = val.first),
                               style: ButtonStyle(
                                 visualDensity: VisualDensity.compact,
                                 textStyle: WidgetStateProperty.all(const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                               ),
                             ),
                             const SizedBox(height: 16),
                             _buildFieldLabel(_t('rateType')),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setStateSheet(() => rateType = 'flat'),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      decoration: BoxDecoration(
                                        color: rateType == 'flat'
                                            ? DairyTheme.primaryTeal.withOpacity(0.12)
                                            : Colors.grey.shade50,
                                        border: Border.all(
                                          color: rateType == 'flat'
                                              ? DairyTheme.primaryTeal
                                              : Colors.grey.shade300,
                                          width: rateType == 'flat' ? 2 : 1,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.straighten_rounded,
                                            color: rateType == 'flat' ? DairyTheme.primaryTeal : Colors.grey,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _t('customer_rate_flat'),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: rateType == 'flat' ? DairyTheme.primaryTeal : Colors.grey[700],
                                            ),
                                          ),
                                          Text(
                                            _t('customer_rate_per_litre'),
                                            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setStateSheet(() => rateType = 'fat'),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 14),
                                      decoration: BoxDecoration(
                                        color: rateType == 'fat'
                                            ? DairyTheme.primaryTeal.withOpacity(0.12)
                                            : Colors.grey.shade50,
                                        border: Border.all(
                                          color: rateType == 'fat'
                                              ? DairyTheme.primaryTeal
                                              : Colors.grey.shade300,
                                          width: rateType == 'fat' ? 2 : 1,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        children: [
                                          Icon(
                                            Icons.water_drop_rounded,
                                            color: rateType == 'fat' ? DairyTheme.primaryTeal : Colors.grey,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _t('customer_rate_fat'),
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: rateType == 'fat' ? DairyTheme.primaryTeal : Colors.grey[700],
                                            ),
                                          ),
                                          Text(
                                            _t('customer_rate_per_fat_point'),
                                            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (rateType == 'flat') ...[
                              _buildFieldLabel(_t('flatRateLabel')),
                              const SizedBox(height: 6),
                              TextField(
                                controller: flatRateController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  hintText: '60',
                                  prefixText: '₹ ',
                                ),
                              ),
                            ] else ...[
                              _buildFieldLabel(_t('ratePerFat')),
                              const SizedBox(height: 6),
                              TextField(
                                controller: fatRateController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: const InputDecoration(
                                  hintText: '6.8',
                                  prefixText: '₹ ',
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(56),
                              ),
                              icon: const Icon(Icons.check_circle_rounded),
                              label: Text(
                                isEdit ? _t('customer_save') : _t('customer_add'),
                                style: const TextStyle(fontSize: 18),
                              ),
                              onPressed: () {
                                final name = nameController.text.trim();
                                  if (name.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(AppLocalizations.get(context, 'customer_name_error')),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                    return;
                                  }

                                final phone = phoneController.text.trim();
                                final address = addressController.text.trim();
                                final qty = double.tryParse(qtyController.text) ?? 1.0;
                                final flatRate = double.tryParse(flatRateController.text) ?? 0.0;
                                final fatRate = double.tryParse(fatRateController.text) ?? 6.8;

                                final updated = Customer(
                                  id: customer?.id,
                                  name: name,
                                  phone: phone.isEmpty ? null : phone,
                                  address: address.isEmpty ? null : address,
                                  defaultQtyL: qty,
                                  rateType: rateType,
                                  flatRate: flatRate,
                                  ratePerFatPoint: fatRate,
                                  partyType: partyType,
                                );

                                if (isEdit) {
                                  context.read<CustomerCubit>().updateCustomer(updated);
                                } else {
                                  context.read<CustomerCubit>().addCustomer(updated);
                                }
                                Navigator.pop(ctx);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
          },
        );
      },
    );
  }

  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
    );
  }

  /// फ़ोन की कॉन्टैक्ट-बुक से ग्राहक चुनो — नाम और नंबर अपने-आप भर जाते हैं।
  ///
  /// अनुमति सिर्फ़ पढ़ने की माँगते हैं; मना करने पर सिर्फ़ snackbar, कोई ज़बरदस्ती नहीं।
  /// फ़ोन की कॉन्टैक्ट-बुक से ग्राहक चुनो — नाम और नंबर अपने-आप भर जाते हैं।
  ///
  /// Sheet **तुरंत** खुलती है (पहले contacts load होने का इंतज़ार होता था —
  /// बड़ी contact-book पर 1-2 सेकंड अटका लगता था)। Loading अब sheet के
  /// अंदर spinner के साथ होती है।
  Future<void> _pickFromContacts(
    BuildContext sheetContext,
    TextEditingController nameController,
    TextEditingController phoneController,
  ) async {
    bool granted = false;
    try {
      granted = await FlutterContacts.requestPermission(readonly: true);
    } catch (_) {}
    if (!granted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_t('contactPermissionDenied')),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    if (!mounted || !sheetContext.mounted) return;

    // load sheet खुलने के साथ-साथ शुरू — एक ही बार चलती है
    final contactsFuture = FlutterContacts.getContacts(
      withProperties: true,
      withThumbnail: false,
    ).then((list) => list.where((c) => c.phones.isNotEmpty).toList());

    showModalBottomSheet(
      context: sheetContext,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        String query = '';
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return SafeArea(
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(ctx).size.height * 0.75,
                ),
                padding: EdgeInsets.only(
                  left: 16,
                  right: 16,
                  top: 10,
                  bottom: MediaQuery.of(ctx).viewInsets.bottom + 12,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 48,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.contact_phone_rounded,
                            color: DairyTheme.primaryTeal),
                        const SizedBox(width: 8),
                        Text(
                          _t('pickFromContacts'),
                          style: const TextStyle(
                              fontSize: 19, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      decoration: InputDecoration(
                        hintText: _t('searchContactHint'),
                        prefixIcon: const Icon(Icons.search_rounded),
                        isDense: true,
                      ),
                      onChanged: (v) =>
                          setSheetState(() => query = v.trim().toLowerCase()),
                    ),
                    const SizedBox(height: 8),
                    Flexible(
                      child: FutureBuilder<List<Contact>>(
                        future: contactsFuture,
                        builder: (ctx, snap) {
                          if (snap.connectionState != ConnectionState.done) {
                            return const Padding(
                              padding: EdgeInsets.all(40),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          final contacts = snap.data ?? const <Contact>[];
                          final shown = query.isEmpty
                              ? contacts
                              : contacts.where((c) {
                                  final name = c.displayName.toLowerCase();
                                  final phones =
                                      c.phones.map((p) => p.number).join(' ');
                                  return name.contains(query) ||
                                      phones.contains(query);
                                }).toList();
                          if (shown.isEmpty) {
                            return Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(_t('noContactsFound'),
                                  style: const TextStyle(color: Colors.grey)),
                            );
                          }
                          return ListView.builder(
                            shrinkWrap: true,
                            itemCount: shown.length,
                            itemBuilder: (_, i) {
                              final c = shown[i];
                              final phone = c.phones.first.number;
                              return ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: DairyTheme.primaryTeal
                                      .withValues(alpha: 0.12),
                                  child: Text(
                                    c.displayName.isNotEmpty
                                        ? c.displayName[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: DairyTheme.primaryTeal),
                                  ),
                                ),
                                title: Text(c.displayName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700)),
                                subtitle: Text(phone),
                                onTap: () {
                                  nameController.text = c.displayName;
                                  phoneController.text = _cleanPhone(phone);
                                  Navigator.pop(ctx);
                                },
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// "+91 98765 43210" → "9876543210" — सिर्फ़ अंक, भारतीय नंबर हो तो आख़िरी 10।
  String _cleanPhone(String raw) {
    var digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length > 10 && digits.startsWith('91')) {
      digits = digits.substring(digits.length - 10);
    } else if (digits.length > 10 && digits.startsWith('0')) {
      digits = digits.substring(digits.length - 10);
    }
    return digits;
  }

  void _confirmDeactivate(BuildContext context, Customer customer) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(_t('warning')),
          content: Text(
            _t('customer_delete_confirm').replaceFirst('{name}', customer.name),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(_t('no')),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
              onPressed: () {
                if (customer.id != null) {
                  context.read<CustomerCubit>().deactivateCustomer(customer.id!);
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
