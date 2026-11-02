import 'package:flutter_test/flutter_test.dart';
import 'package:kaajo_core/content/catalog.dart';
import 'package:kaajo_core/models/booking.dart';
import 'package:kaajo_core/utils/format.dart';

void main() {
  test('rupees uses Indian grouping', () {
    expect(rupees(600), '₹600');
    expect(rupees(2400), '₹2,400');
    expect(rupees(125000), '₹1,25,000');
    expect(rupees(10000000), '₹1,00,00,000');
  });

  test('mobile validation', () {
    expect(isValidMobile('9876543210'), isTrue);
    expect(isValidMobile('+91 98765 43210'), isTrue);
    expect(isValidMobile('1234567890'), isFalse);
    expect(isValidMobile('98765'), isFalse);
  });

  test('date chip labels', () {
    final now = DateTime(2026, 11, 2, 10);
    expect(dateChipLabel(DateTime(2026, 11, 2), now), 'आज');
    expect(dateChipLabel(DateTime(2026, 11, 3), now), 'कल');
    expect(nextDays(7, now).length, 7);
    expect(nextDays(7, now).first, DateTime(2026, 11, 3));
  });

  test('cleaning price grows above 3 kW', () {
    expect(Catalog.solarCleaning.estimateFor(3), 600);
    expect(Catalog.solarCleaning.estimateFor(5), 900);
    expect(Catalog.solarRepair.estimateFor(5), 500);
  });

  test('booking survives JSON round trip', () {
    final b = Booking(
      id: 'NB-0211-1234',
      serviceId: 'solar_cleaning',
      serviceTitle: 'सोलर पैनल सफ़ाई',
      customerName: 'राम',
      mobile: '9876543210',
      address: 'Shivpur',
      area: 'Shivpur',
      systemKw: 3,
      date: DateTime(2026, 11, 3),
      timeSlot: 'सुबह 7–10',
      estimatedPrice: 600,
      createdAt: DateTime(2026, 11, 2),
    );
    final back = Booking.fromJson(b.toJson());
    expect(back.id, b.id);
    expect(back.status, BookingStatus.sent);
    expect(back.copyWith(status: BookingStatus.done).status, BookingStatus.done);
  });
}
