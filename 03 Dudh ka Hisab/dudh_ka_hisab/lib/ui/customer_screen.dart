import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../blocs/customer_cubit.dart';
import '../../db/models/customer.dart';
import '../../l10n/app_localizations.dart';

class CustomerScreen extends StatelessWidget {
  const CustomerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.get(context, 'customers')),
      ),
      body: BlocBuilder<CustomerCubit, CustomerState>(
        builder: (context, state) {
          if (state is CustomerLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CustomerListLoaded) {
            final list = state.customers;
            if (list.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people_outline_rounded, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 12),
                    const Text('कोई ग्राहक नहीं है।', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  ],
                ),
              );
            }

            final nf = NumberFormat('#,##,##0', 'en_IN');

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: list.length,
              itemBuilder: (context, idx) {
                final customer = list[idx];
                final due = state.dues[customer.id] ?? 0.0;
                final isDue = due > 0;
                final isAdv = due < 0;
                final dueColor = isDue
                    ? Colors.red[800]
                    : isAdv
                        ? Colors.green[800]
                        : Colors.grey[600];

                final dueText = isDue
                    ? '₹${nf.format(due.abs())} बाकी'
                    : isAdv
                        ? '₹${nf.format(due.abs())} एडवांस'
                        : 'हिसाब बराबर';

                return Card(
                  child: ListTile(
                    title: Text(
                      customer.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    subtitle: Text(
                      '${customer.defaultQtyL.toStringAsFixed(1)} ली/रोज | ${customer.rateType == 'flat' ? 'फ्लैट: ₹' + customer.flatRate.toStringAsFixed(1) : 'फैट आधारित'}',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          dueText,
                          style: TextStyle(
                            color: dueColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.edit_note_rounded, color: Colors.blue),
                          onPressed: () => _showAddEditDialog(context, customer: customer),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_sweep_rounded, color: Colors.red),
                          onPressed: () => _confirmDeactivate(context, customer),
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/customer_detail',
                        arguments: customer,
                      ).then((_) {
                        context.read<CustomerCubit>().loadCustomers();
                      });
                    },
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: Text(AppLocalizations.get(context, 'addCustomer'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).primaryColor,
        onPressed: () => _showAddEditDialog(context),
      ),
    );
  }

  void _showAddEditDialog(BuildContext context, {Customer? customer}) {
    final nameController = TextEditingController(text: customer?.name ?? '');
    final phoneController = TextEditingController(text: customer?.phone ?? '');
    final flatRateController = TextEditingController(text: customer?.flatRate.toString() ?? '60');
    final qtyController = TextEditingController(text: customer?.defaultQtyL.toString() ?? '1.0');
    String rateType = customer?.rateType ?? 'flat';

    final isEdit = customer != null;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(isEdit ? 'ग्राहक सुधारें' : AppLocalizations.get(context, 'addCustomer')),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: AppLocalizations.get(context, 'customerName')),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(labelText: AppLocalizations.get(context, 'phoneNumber')),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: qtyController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: AppLocalizations.get(context, 'defaultQtyLabel')),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: rateType,
                      decoration: InputDecoration(labelText: AppLocalizations.get(context, 'rateType')),
                      items: [
                        DropdownMenuItem(value: 'flat', child: Text(AppLocalizations.get(context, 'flat'))),
                        DropdownMenuItem(value: 'fat', child: Text(AppLocalizations.get(context, 'fatBased'))),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setStateDialog(() {
                            rateType = val;
                          });
                        }
                      },
                    ),
                    if (rateType == 'flat') ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: flatRateController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: InputDecoration(labelText: AppLocalizations.get(context, 'flatRateLabel')),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(AppLocalizations.get(context, 'cancel')),
                ),
                ElevatedButton(
                  onPressed: () {
                    final name = nameController.text.trim();
                    if (name.isEmpty) return;

                    final phone = phoneController.text.trim();
                    final qty = double.tryParse(qtyController.text) ?? 1.0;
                    final flatRate = double.tryParse(flatRateController.text) ?? 0.0;

                    final updated = Customer(
                      id: customer?.id,
                      name: name,
                      phone: phone.isEmpty ? null : phone,
                      defaultQtyL: qty,
                      rateType: rateType,
                      flatRate: flatRate,
                    );

                    if (isEdit) {
                      context.read<CustomerCubit>().updateCustomer(updated);
                    } else {
                      context.read<CustomerCubit>().addCustomer(updated);
                    }
                    Navigator.pop(ctx);
                  },
                  child: Text(AppLocalizations.get(context, 'save')),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeactivate(BuildContext context, Customer customer) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(AppLocalizations.get(context, 'warning')),
          content: Text('क्या आप सच में ${customer.name} को हटाना चाहते हैं?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLocalizations.get(context, 'no')),
            ),
            ElevatedButton(
              onPressed: () {
                if (customer.id != null) {
                  context.read<CustomerCubit>().deactivateCustomer(customer.id!);
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
