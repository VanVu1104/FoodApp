import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:demo_firebase/repo/payment.dart';
import 'package:intl/intl.dart';
import 'package:sprintf/sprintf.dart';

class Utils {
  String formatCurrency(num amount) {
    final format = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return format.format(amount);
  }

  /// Function Format DateTime to String with layout string
  String formatNumber(double value) {
    final f = new NumberFormat("#,###", "vi_VN");
    return f.format(value);
  }

  /// Function Format DateTime to String with layout string
  static String formatDateTime(DateTime dateTime, String layout) {
    return DateFormat(layout).format(dateTime).toString();
  }

  static int transIdDefault = 1; // Cũng phải để static

  static String getAppTransId() {
    if (transIdDefault >= 100000) {
      transIdDefault = 1;
    }

    transIdDefault += 1;
    var timeString = formatDateTime(DateTime.now(), "yyMMdd_hhmmss");
    return sprintf("%s%06d", [timeString, transIdDefault]);
  }

  static String getBankCode() => "zalopayapp";
  static String getDescription(String apptransid) =>
      "Merchant Demo thanh toán cho đơn hàng  #$apptransid";

  static String getMacCreateOrder(String data) {
    var hmac = new Hmac(sha256, utf8.encode(ZaloPayConfig.key1));
    return hmac.convert(utf8.encode(data)).toString();
  }
}
