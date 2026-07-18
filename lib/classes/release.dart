import 'package:dynamic_value/dynamic_value.dart';

class Release {
  String? link;
  String? version;
  String? publishedDate;
  String? body;

  Release({
    required this.link,
    required this.version,
    required this.publishedDate,
    required this.body,
  });

  factory Release.fromJSON(dynamic json) {
    final value = DynamicValue(json);

    return Release(
      link: value['html_url'].toString(),
      version: value['tag_name'].toString(),
      publishedDate: value['published_at'].toString(),
      body: (value['body'].toString().length > 4000 ? '${value['body'].toString().substring(0, 4000)}...' : value['body'].toString()),
    );
  }

  @override
  String toString() {
    return 'Release{link: $link, version: $version, publishedDate: $publishedDate}';
  }
}
