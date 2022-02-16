import 'package:dynamic_value/dynamic_value.dart';

class Repository{

  int? id;
  String? name;
  String? link;

  Repository({required this.id, required this.name, required this.link });

  factory Repository.fromJSON(dynamic json) {

    final value = DynamicValue(json);

    return Repository(
      id: value['id'].toInt,
      name: value['name'].toString(),
      link: value['svn_url'].toString()
     );
  }

  @override
  String toString() {
    return 'Repository {\n   id: $id,\n   name: $name,\n   link: $link\n}';
  }
}