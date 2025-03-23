import 'package:intl/intl.dart';

class Utils {
  String formatCurrency(num amount) {
    final format = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return format.format(amount);
  }
}
