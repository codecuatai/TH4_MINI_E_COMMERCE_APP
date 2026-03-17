import 'package:intl/intl.dart';

class Utils {
  static String formatCurrency(num value) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: 'đ').format(value);
  }
}
