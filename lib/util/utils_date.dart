import 'package:jiffy/jiffy.dart';

class UtilsDate {
  static const String formatPtBr = "dd/MM/yyyy";
  static const String formatUS = "dd/MM/yyyy";

  static String format(String date, {String pattern = formatPtBr}) {
    if (date.isEmpty) return "";

    return Jiffy.parse(date).format(pattern: pattern);
  }
}
