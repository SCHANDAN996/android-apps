/// टेक्नीशियन की कमाई के सुझाए रेट (docs/TECHNICIAN_AND_SERVER_PLAN.md, सेक्शन 3)।
///
/// रेट पक्के होने पर (या v0.2 में सर्वर आने पर) इन्हें `nischint_core` के config में
/// ले जाना है, ताकि दोनों ऐप एक ही जगह से पढ़ें।
class TechnicianRates {
  TechnicianRates._();

  /// हर विज़िट की मेहनत।
  static const int perVisit = 200;

  /// पेट्रोल भत्ता, प्रति विज़िट।
  static const int petrol = 30;

  /// जल्दी वाली (48 घंटे) विज़िट पर ज़्यादा।
  static const int urgentBonus = 50;

  /// 3 kW से बड़े सिस्टम की सफ़ाई पर, हर अतिरिक्त kW का।
  static const int extraPerKwAbove3 = 50;

  /// एक विज़िट की कुल कमाई।
  /// [cleaningKw] सिर्फ़ सफ़ाई वाले काम में दें (3 kW से ऊपर हर kW पर [extraPerKwAbove3])।
  static int earning({bool urgent = false, int cleaningKw = 0}) {
    var total = perVisit + petrol;
    if (urgent) total += urgentBonus;
    if (cleaningKw > 3) total += (cleaningKw - 3) * extraPerKwAbove3;
    return total;
  }

  /// ग्राहक की नकद बुकिंग का हिसाब।
  static JobMoney cashBooking({required int customerPays, bool urgent = false, int cleaningKw = 0}) {
    final earn = earning(urgent: urgent, cleaningKw: cleaningKw);
    return JobMoney(customerPays: customerPays, earning: earn, depositToCompany: customerPays - earn);
  }

  /// वेंडर की शिकायत का हिसाब: ग्राहक से कुछ नहीं, वेंडर महीने के बिल से देगा।
  static JobMoney vendorComplaint({bool urgent = false}) =>
      JobMoney(customerPays: 0, earning: earning(urgent: urgent), depositToCompany: 0);
}

/// एक काम का पैसा: ग्राहक से लेना, आपकी कमाई, कंपनी को जमा।
class JobMoney {
  const JobMoney({required this.customerPays, required this.earning, required this.depositToCompany});

  final int customerPays;
  final int earning;
  final int depositToCompany;
}
