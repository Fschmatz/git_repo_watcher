import 'package:dynamic_value/dynamic_value.dart';

class Release{

  String? link;
  String? version;
  String? publishedDate;

  Release({
    required this.link,
    required this.version,
    required this.publishedDate,
  });

  factory Release.fromJSON(dynamic json) {

    final value = DynamicValue(json);

    return Release(
      link: value['html_url'].toString(),
      version: value['tag_name'].toString(),
      publishedDate: value['published_at'].toString(),
    );
  }

}