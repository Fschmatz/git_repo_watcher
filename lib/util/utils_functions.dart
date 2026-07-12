import 'package:jiffy/jiffy.dart';

import 'app_constants.dart';

//------------- BACKUP
String getBackupFilename() {
  String name = AppConstants.backupFileName;
  String dateTimeStr = Jiffy.now().format(pattern: 'dd_MM_yyyy_HHmmss');

  return '${name}_$dateTimeStr.json';
}

String capitalizeFirstLetterString(String word) {
  return word.replaceFirst(word[0], word[0].toUpperCase());
}

String removeHtmlTags(String words) {
  return words.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '');
}
