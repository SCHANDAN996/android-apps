import 'package:flutter_bloc/flutter_bloc.dart';
import '../db/dao/customer_dao.dart';
import '../db/dao/payment_dao.dart';
import '../db/models/customer.dart';

/// States for customer management.
abstract class CustomerState {}

class CustomerInitial extends CustomerState {}

class CustomerLoading extends CustomerState {}

class CustomerListLoaded extends CustomerState {
  final List<Customer> customers;
  final Map<int, double> dues; // customerId -> due amount
  CustomerListLoaded({required this.customers, required this.dues});
}

class CustomerSaved extends CustomerState {
  final String message;
  CustomerSaved(this.message);
}

class CustomerError extends CustomerState {
  final String message;
  CustomerError(this.message);
}

/// Cubit for customer CRUD and dues calculation.
class CustomerCubit extends Cubit<CustomerState> {
  final CustomerDao _customerDao = CustomerDao();
  final PaymentDao _paymentDao = PaymentDao();

  CustomerCubit() : super(CustomerInitial());

  /// Load all active customers with their dues.
  Future<void> loadCustomers() async {
    emit(CustomerLoading());
    final customers = await _customerDao.getActiveCustomers();
    final dues = <int, double>{};

    for (final c in customers) {
      if (c.id != null) {
        dues[c.id!] = await _paymentDao.getCustomerDue(c.id!);
      }
    }

    emit(CustomerListLoaded(customers: customers, dues: dues));
  }

  /// Add a new customer.
  Future<void> addCustomer(Customer customer) async {
    emit(CustomerLoading());
    await _customerDao.insertCustomer(customer);
    emit(CustomerSaved('✅ ग्राहक जोड़ दिया!'));
    await loadCustomers();
  }

  /// Update an existing customer.
  Future<void> updateCustomer(Customer customer) async {
    emit(CustomerLoading());
    await _customerDao.updateCustomer(customer);
    emit(CustomerSaved('✅ ग्राहक अपडेट हो गया!'));
    await loadCustomers();
  }

  /// Deactivate (soft-delete) a customer.
  Future<void> deactivateCustomer(int customerId) async {
    emit(CustomerLoading());
    await _customerDao.deactivateCustomer(customerId);
    emit(CustomerSaved('ग्राहक हटा दिया गया'));
    await loadCustomers();
  }
}
