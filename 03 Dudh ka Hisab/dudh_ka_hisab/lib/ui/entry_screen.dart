import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../blocs/app_cubit.dart';
import '../../blocs/entry_cubit.dart';
import '../../blocs/customer_cubit.dart';
import '../../l10n/app_localizations.dart';
import '../../db/models/milk_entry.dart';
import '../../db/models/customer.dart';

class EntryScreen extends StatefulWidget {
  final MilkEntry? editEntry;
  const EntryScreen({super.key, this.editEntry});

  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  late DateTime _selectedDate;
  late String _shift; // 'M' or 'E'
  Customer? _selectedCustomer;
  String _qtyString = "";
  String _fatString = "";
  bool _editingFat = false; // toggles keypad input target

  double _computedAmount = 0.0;
  double _computedRate = 0.0;

  @override
  void initState() {
    super.initState();

    final isEdit = widget.editEntry != null;
    _selectedDate = isEdit ? DateFormat('dd-MM-yyyy').parse(widget.editEntry!.date) : DateTime.now();
    _shift = isEdit ? widget.editEntry!.shift : _getDefaultShift();
    _qtyString = isEdit ? widget.editEntry!.qtyL.toString() : "1.0";
    _fatString = isEdit && widget.editEntry!.fatPct != null ? widget.editEntry!.fatPct.toString() : "";

    // Load active customers if doodhwala mode
    final appState = context.read<AppCubit>().state;
    if (appState.isDoodhwalaMode) {
      final customerCubit = context.read<CustomerCubit>();
      if (customerCubit.state is CustomerListLoaded) {
        final list = (customerCubit.state as CustomerListLoaded).customers;
        if (list.isNotEmpty) {
          if (isEdit) {
            _selectedCustomer = list.firstWhere(
              (c) => c.id == widget.editEntry!.customerId,
              orElse: () => list.first,
            );
          } else {
            _selectedCustomer = list.first;
            _qtyString = _selectedCustomer!.defaultQtyL.toString();
          }
        }
      }
    }

    _calculateLiveAmount();
  }

  String _getDefaultShift() {
    final hour = DateTime.now().hour;
    return hour < 14 ? 'M' : 'E';
  }

  void _calculateLiveAmount() {
    final appState = context.read<AppCubit>().state;
    final qty = double.tryParse(_qtyString) ?? 0.0;
    final fat = double.tryParse(_fatString) ?? 0.0;

    double rate = 0.0;
    String rateType = appState.rateType;

    if (appState.isDoodhwalaMode && _selectedCustomer != null) {
      rateType = _selectedCustomer!.rateType;
      rate = _selectedCustomer!.flatRate;
    } else {
      rate = appState.flatRate;
    }

    if (rateType == 'fat') {
      final ratePerFat = appState.isDoodhwalaMode ? 6.8 : appState.ratePerFatPoint;
      rate = fat * ratePerFat;
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

  void _incrementQty(double delta) {
    final current = double.tryParse(_qtyString) ?? 0.0;
    final updated = (current + delta).clamp(0.0, 999.0);
    setState(() {
      _qtyString = updated.toStringAsFixed(1);
      _calculateLiveAmount();
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppCubit>().state;
    final isEdit = widget.editEntry != null;

    return BlocListener<EntryCubit, EntryState>(
      listener: (context, state) {
        if (state is EntrySaved) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.green),
          );
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
          title: Text(isEdit ? AppLocalizations.get(context, 'edit') : AppLocalizations.get(context, 'todayEntry')),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildDateAndShiftRow(context),
                  const SizedBox(height: 12),
                  if (appState.isDoodhwalaMode) ...[
                    _buildCustomerPicker(context),
                    const SizedBox(height: 12),
                  ],
                  _buildInputFieldsRow(context, appState),
                  const SizedBox(height: 12),
                  _buildLiveReceiptCard(context),
                ],
              ),
            ),
            _buildCustomKeypad(context, appState),
          ],
        ),
      ),
    );
  }

  Widget _buildDateAndShiftRow(BuildContext context) {
    final formattedDate = DateFormat('dd-MM-yyyy').format(_selectedDate);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
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
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 8),
                    Text(
                      formattedDate,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
            Container(width: 1, height: 30, color: Colors.grey.shade300),
            const SizedBox(width: 16),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(
                  value: 'M',
                  label: Text(AppLocalizations.get(context, 'morning')),
                  icon: const Icon(Icons.wb_sunny_rounded, size: 16),
                ),
                ButtonSegment(
                  value: 'E',
                  label: Text(AppLocalizations.get(context, 'evening')),
                  icon: const Icon(Icons.nights_stay_rounded, size: 16),
                ),
              ],
              selected: {_shift},
              onSelectionChanged: (val) {
                setState(() {
                  _shift = val.first;
                });
              },
              showSelectedIcon: false,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerPicker(BuildContext context) {
    final customerState = context.watch<CustomerCubit>().state;
    List<Customer> list = [];
    if (customerState is CustomerListLoaded) {
      list = customerState.customers;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            Icon(Icons.person_rounded, color: Theme.of(context).primaryColor),
            const SizedBox(width: 16),
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Customer>(
                  value: _selectedCustomer,
                  isExpanded: true,
                  hint: const Text('ग्राहक चुनें'),
                  items: list.map((c) {
                    return DropdownMenuItem(
                      value: c,
                      child: Text(c.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedCustomer = val;
                      if (val != null) {
                        _qtyString = val.defaultQtyL.toString();
                      }
                      _calculateLiveAmount();
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputFieldsRow(BuildContext context, AppState appState) {
    final isFat = appState.isFatBased || (_selectedCustomer != null && _selectedCustomer!.rateType == 'fat');

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _editingFat = false;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: !_editingFat ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: !_editingFat ? Theme.of(context).primaryColor : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Text(AppLocalizations.get(context, 'litres'), style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 4),
                  Text(
                    _qtyString.isEmpty ? "0" : _qtyString,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isFat) ...[
          const SizedBox(width: 16),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _editingFat = true;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _editingFat ? Theme.of(context).primaryColor.withOpacity(0.1) : Colors.white,
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
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLiveReceiptCard(BuildContext context) {
    final nf = NumberFormat('#,##,##0', 'en_IN');
    return Card(
      elevation: 0,
      color: Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppLocalizations.get(context, 'rate'), style: const TextStyle(fontSize: 16)),
                Text('₹ ${_computedRate.toStringAsFixed(2)} /ली', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(AppLocalizations.get(context, 'amount'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text('₹ ${nf.format(_computedAmount)}', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold, fontSize: 22)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomKeypad(BuildContext context, AppState appState) {
    return Container(
      color: Colors.grey.shade200,
      padding: const EdgeInsets.all(8),
      child: Column(
        children: [
          // Row containing increments for rapid entry
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
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Row(
                      children: [
                        _buildKey("1"),
                        _buildKey("2"),
                        _buildKey("3"),
                      ],
                    ),
                    Row(
                      children: [
                        _buildKey("4"),
                        _buildKey("5"),
                        _buildKey("6"),
                      ],
                    ),
                    Row(
                      children: [
                        _buildKey("7"),
                        _buildKey("8"),
                        _buildKey("9"),
                      ],
                    ),
                    Row(
                      children: [
                        _buildKey("."),
                        _buildKey("0"),
                        _buildKey("clear", icon: Icons.backspace_rounded),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 90,
                height: 240,
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
    );
  }

  Widget _buildIncrementBtn(String label) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
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
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: SizedBox(
          height: 52,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => _onKeypadTap(value),
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
        const SnackBar(content: Text('कृपया सही लीटर डालें'), backgroundColor: Colors.orange),
      );
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
