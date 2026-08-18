import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../blocs/app_cubit.dart';
import '../../blocs/entry_cubit.dart';
import '../../blocs/customer_cubit.dart';
import '../../l10n/app_localizations.dart';
import '../../services/ad_service.dart';
import '../../db/models/milk_entry.dart';
import '../../db/dao/customer_dao.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CustomerDao _customerDao = CustomerDao();

  @override
  void initState() {
    super.initState();
    // Load home data and customer data on init
    context.read<EntryCubit>().loadHomeData();
    if (context.read<AppCubit>().state.isDoodhwalaMode) {
      context.read<CustomerCubit>().loadCustomers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, appState) {
        return Scaffold(
          appBar: AppBar(
            title: Text(AppLocalizations.get(context, 'appName')),
            actions: [
              if (appState.isDoodhwalaMode)
                IconButton(
                  icon: const Icon(Icons.people_alt_rounded),
                  tooltip: AppLocalizations.get(context, 'customers'),
                  onPressed: () {
                    Navigator.pushNamed(context, '/customers').then((_) {
                      context.read<EntryCubit>().loadHomeData();
                      context.read<CustomerCubit>().loadCustomers();
                    });
                  },
                ),
              IconButton(
                icon: const Icon(Icons.analytics_outlined),
                tooltip: AppLocalizations.get(context, 'monthlyReport'),
                onPressed: () {
                  AdService.instance.showInterstitialAd(() {
                    Navigator.pushNamed(context, '/report');
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.settings_rounded),
                tooltip: AppLocalizations.get(context, 'settings'),
                onPressed: () {
                  Navigator.pushNamed(context, '/settings').then((_) {
                    context.read<EntryCubit>().loadHomeData();
                    if (appState.isDoodhwalaMode) {
                      context.read<CustomerCubit>().loadCustomers();
                    }
                  });
                },
              ),
            ],
          ),
          body: BlocBuilder<EntryCubit, EntryState>(
            builder: (context, entryState) {
              if (entryState is EntryLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              List<MilkEntry> recentEntries = [];
              Map<String, double> monthlyTotals = {
                'totalLitres': 0.0,
                'totalAmount': 0.0,
              };

              if (entryState is EntryListLoaded) {
                recentEntries = entryState.entries;
                monthlyTotals = entryState.monthlyTotals;
              }

              return Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _buildSummaryCard(context, monthlyTotals),
                        const SizedBox(height: 16),
                        if (appState.isDoodhwalaMode) ...[
                          _buildCustomerHorizontalList(context),
                          const SizedBox(height: 16),
                        ],
                        _buildBigEntryButton(context),
                        const SizedBox(height: 24),
                        _buildRecentEntriesHeader(context),
                        const SizedBox(height: 8),
                        if (recentEntries.isEmpty)
                          _buildEmptyState(context)
                        else
                          _buildRecentEntriesList(context, recentEntries, appState),
                      ],
                    ),
                  ),
                  AdService.instance.getBannerAdWidget(),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(BuildContext context, Map<String, double> totals) {
    final nf = NumberFormat('#,##,##0', 'en_IN');
    final litres = totals['totalLitres'] ?? 0.0;
    final amount = totals['totalAmount'] ?? 0.0;

    final currentMonthName = DateFormat('MMMM', context.read<AppCubit>().state.language == 'hi' ? 'hi' : 'en').format(DateTime.now());

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: Theme.of(context).primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$currentMonthName का हिसाब',
              style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${litres.toStringAsFixed(1)} लिटर',
                      style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      AppLocalizations.get(context, 'totalLitres'),
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white30,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '₹ ${nf.format(amount)}',
                      style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      AppLocalizations.get(context, 'totalAmount'),
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerHorizontalList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            AppLocalizations.get(context, 'customers'),
            style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
          ),
        ),
        SizedBox(
          height: 90,
          child: BlocBuilder<CustomerCubit, CustomerState>(
            builder: (context, state) {
              if (state is CustomerListLoaded) {
                final list = state.customers;
                if (list.isEmpty) {
                  return InkWell(
                    onTap: () => Navigator.pushNamed(context, '/customers').then((_) {
                      context.read<CustomerCubit>().loadCustomers();
                    }),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Icon(Icons.add_circle_outline, color: Theme.of(context).primaryColor),
                            const SizedBox(width: 8),
                            const Text('कोई ग्राहक नहीं। यहाँ से जोड़ें', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: list.length,
                  itemBuilder: (context, idx) {
                    final customer = list[idx];
                    final due = state.dues[customer.id] ?? 0.0;
                    return _buildCustomerHorizontalCard(context, customer.name, due, () {
                      Navigator.pushNamed(
                        context,
                        '/customer_detail',
                        arguments: customer,
                      ).then((_) {
                        context.read<EntryCubit>().loadHomeData();
                        context.read<CustomerCubit>().loadCustomers();
                      });
                    });
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerHorizontalCard(
    BuildContext context,
    String name,
    double due,
    VoidCallback onTap,
  ) {
    final nf = NumberFormat('#,##,##0', 'en_IN');
    final isDue = due > 0;
    final isAdv = due < 0;
    final badgeColor = isDue
        ? Colors.red[800]
        : isAdv
            ? Colors.green[800]
            : Colors.grey[600];

    final text = isDue
        ? '₹${nf.format(due.abs())} ${AppLocalizations.get(context, 'due')}'
        : isAdv
            ? '₹${nf.format(due.abs())} ${AppLocalizations.get(context, 'advance')}'
            : '₹0';

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 120,
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor?.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  text,
                  style: TextStyle(color: badgeColor, fontSize: 12, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBigEntryButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 65,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.add_circle, size: 28, color: Colors.white),
        label: Text(
          AppLocalizations.get(context, 'todayEntry'),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          Navigator.pushNamed(context, '/entry').then((_) {
            context.read<EntryCubit>().loadHomeData();
            if (context.read<AppCubit>().state.isDoodhwalaMode) {
              context.read<CustomerCubit>().loadCustomers();
            }
          });
        },
      ),
    );
  }

  Widget _buildRecentEntriesHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        AppLocalizations.get(context, 'recentEntries'),
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(Icons.history_toggle_off_rounded, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              AppLocalizations.get(context, 'noEntries'),
              style: TextStyle(color: Colors.grey[600], fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentEntriesList(
    BuildContext context,
    List<MilkEntry> entries,
    AppState appState,
  ) {
    final nf = NumberFormat('#,##,##0', 'en_IN');
    return Column(
      children: entries.map((entry) {
        final date = entry.date;
        final shift = entry.shift == 'M'
            ? AppLocalizations.get(context, 'morning')
            : AppLocalizations.get(context, 'evening');
        final shiftIcon = entry.shift == 'M' ? Icons.wb_sunny_rounded : Icons.nights_stay_rounded;
        final shiftColor = entry.shift == 'M' ? Colors.orange[800] : Colors.indigo[800];

        return Card(
          key: ValueKey(entry.id),
          child: InkWell(
            onLongPress: () {
              _showEntryActions(context, entry);
            },
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: shiftColor?.withOpacity(0.1),
                child: Icon(shiftIcon, color: shiftColor),
              ),
              title: FutureBuilder<String>(
                future: _getCustomerName(entry.customerId, appState),
                builder: (context, snapshot) {
                  return Text(
                    snapshot.data ?? 'किसान खाता',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  );
                },
              ),
              subtitle: Text(
                '$date | $shift',
                style: const TextStyle(fontSize: 14),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${entry.qtyL.toStringAsFixed(1)} लिटर',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Text(
                    '₹ ${nf.format(entry.amount)}',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<String> _getCustomerName(int? id, AppState appState) async {
    if (id == null || !appState.isDoodhwalaMode) {
      return 'किसान खाता';
    }
    final customers = await _customerDao.getCustomerById(id);
    return customers?.name ?? 'अनजान ग्राहक';
  }

  void _showEntryActions(BuildContext context, MilkEntry entry) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.edit_rounded, color: Colors.blue),
                title: Text(AppLocalizations.get(context, 'edit')),
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.pushNamed(context, '/entry', arguments: entry).then((_) {
                    context.read<EntryCubit>().loadHomeData();
                    if (context.read<AppCubit>().state.isDoodhwalaMode) {
                      context.read<CustomerCubit>().loadCustomers();
                    }
                  });
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever_rounded, color: Colors.red),
                title: Text(AppLocalizations.get(context, 'delete')),
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
          title: Text(AppLocalizations.get(context, 'warning')),
          content: const Text('क्या आप इस एंट्री को हमेशा के लिए हटाना चाहते हैं?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLocalizations.get(context, 'no')),
            ),
            ElevatedButton(
              onPressed: () {
                if (entry.id != null) {
                  context.read<EntryCubit>().deleteEntry(entry.id!);
                }
                Navigator.pop(ctx);
              },
              child: Text(AppLocalizations.get(context, 'yes')),
            ),
          ],
        );
      },
    );
  }
}
