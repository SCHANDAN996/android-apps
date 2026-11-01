import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/booking.dart';
import '../models/complaint.dart';
import '../models/profiles.dart';

/// पूरे ऐप का डेटा: भूमिका, प्रोफ़ाइल, बुकिंग, शिकायतें।
/// सब कुछ फ़ोन में (SharedPreferences) सेव होता है।
class AppState extends ChangeNotifier {
  static const _kRole = 'role';
  static const _kOnboarded = 'onboarded';
  static const _kCustomer = 'customer_profile';
  static const _kVendor = 'vendor_profile';
  static const _kBookings = 'bookings';
  static const _kComplaints = 'complaints';

  SharedPreferences? _prefs;

  bool _loaded = false;
  bool _onboarded = false;
  AppRole? _role;
  CustomerProfile _customer = const CustomerProfile();
  VendorProfile _vendor = const VendorProfile();
  List<Booking> _bookings = [];
  List<VendorComplaint> _complaints = [];

  bool get loaded => _loaded;
  bool get onboarded => _onboarded;
  AppRole? get role => _role;
  CustomerProfile get customer => _customer;
  VendorProfile get vendor => _vendor;

  /// नई बुकिंग सबसे ऊपर।
  List<Booking> get bookings => List.unmodifiable(_bookings);

  /// नई शिकायत सबसे ऊपर।
  List<VendorComplaint> get complaints => List.unmodifiable(_complaints);

  int get openComplaints =>
      _complaints.where((c) => c.status != ComplaintStatus.resolved).length;
  int get resolvedComplaints =>
      _complaints.where((c) => c.status == ComplaintStatus.resolved).length;

  Future<void> load() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      final p = _prefs!;
      _onboarded = p.getBool(_kOnboarded) ?? false;
      final roleName = p.getString(_kRole);
      _role = null;
      for (final r in AppRole.values) {
        if (r.name == roleName) _role = r;
      }
      _customer = _decodeObject(p.getString(_kCustomer), CustomerProfile.fromJson) ??
          const CustomerProfile();
      _vendor = _decodeObject(p.getString(_kVendor), VendorProfile.fromJson) ??
          const VendorProfile();
      _bookings = _decodeList(p.getString(_kBookings), Booking.fromJson);
      _complaints = _decodeList(p.getString(_kComplaints), VendorComplaint.fromJson);
    } catch (e) {
      debugPrint('AppState.load failed: $e');
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> completeOnboarding(AppRole role) async {
    _onboarded = true;
    _role = role;
    await _prefs?.setBool(_kOnboarded, true);
    await _prefs?.setString(_kRole, role.name);
    notifyListeners();
  }

  Future<void> setRole(AppRole role) async {
    _role = role;
    await _prefs?.setString(_kRole, role.name);
    notifyListeners();
  }

  Future<void> saveCustomer(CustomerProfile profile) async {
    _customer = profile;
    await _prefs?.setString(_kCustomer, jsonEncode(profile.toJson()));
    notifyListeners();
  }

  Future<void> saveVendor(VendorProfile profile) async {
    _vendor = profile;
    await _prefs?.setString(_kVendor, jsonEncode(profile.toJson()));
    notifyListeners();
  }

  Future<void> addBooking(Booking booking) async {
    _bookings = [booking, ..._bookings];
    await _saveBookings();
  }

  Future<void> updateBookingStatus(String id, BookingStatus status) async {
    _bookings = [
      for (final b in _bookings) b.id == id ? b.copyWith(status: status) : b,
    ];
    await _saveBookings();
  }

  Future<void> addComplaint(VendorComplaint complaint) async {
    _complaints = [complaint, ..._complaints];
    await _saveComplaints();
  }

  Future<void> updateComplaintStatus(String id, ComplaintStatus status) async {
    _complaints = [
      for (final c in _complaints) c.id == id ? c.copyWith(status: status) : c,
    ];
    await _saveComplaints();
  }

  /// सारा डेटा मिटाकर ऐप को नए जैसा करना (सेटिंग से)।
  Future<void> clearAll() async {
    await _prefs?.clear();
    _onboarded = false;
    _role = null;
    _customer = const CustomerProfile();
    _vendor = const VendorProfile();
    _bookings = [];
    _complaints = [];
    notifyListeners();
  }

  /// बुकिंग नंबर, जैसे NB-0211-4821 (दिन+महीना और 4 अंक)।
  static String newBookingId() => _newId('NB');

  /// शिकायत नंबर, जैसे VC-0211-1934।
  static String newComplaintId() => _newId('VC');

  static String _newId(String prefix) {
    final now = DateTime.now();
    final dd = now.day.toString().padLeft(2, '0');
    final mm = now.month.toString().padLeft(2, '0');
    final rand = (1000 + Random().nextInt(9000)).toString();
    return '$prefix-$dd$mm-$rand';
  }

  Future<void> _saveBookings() async {
    await _prefs?.setString(
        _kBookings, jsonEncode(_bookings.map((b) => b.toJson()).toList()));
    notifyListeners();
  }

  Future<void> _saveComplaints() async {
    await _prefs?.setString(
        _kComplaints, jsonEncode(_complaints.map((c) => c.toJson()).toList()));
    notifyListeners();
  }

  static T? _decodeObject<T>(String? raw, T Function(Map<String, dynamic>) fromJson) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final v = jsonDecode(raw);
      if (v is Map<String, dynamic>) return fromJson(v);
    } catch (_) {
      // ख़राब डेटा हो तो अनदेखा करें।
    }
    return null;
  }

  static List<T> _decodeList<T>(String? raw, T Function(Map<String, dynamic>) fromJson) {
    if (raw == null || raw.isEmpty) return [];
    try {
      final v = jsonDecode(raw);
      if (v is List) {
        return v.whereType<Map<String, dynamic>>().map(fromJson).toList();
      }
    } catch (_) {
      // ख़राब डेटा हो तो अनदेखा करें।
    }
    return [];
  }
}
