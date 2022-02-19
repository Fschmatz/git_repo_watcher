import 'package:dynamic_value/dynamic_value.dart';

class Repository{

  int? id;
  int? idGit;
  String? name;
  String? owner;
  String? link;
  String? lastUpdate;
  String? createdDate;
  String? releaseLink;
  String? releaseVersion;
  String? releasePublishedDate;

  Repository({
    this.id,
    required this.idGit,
    required this.name,
    required this.link,
    required this.owner,
    required this.lastUpdate,
    required this.createdDate,
    this.releaseLink,
    this.releaseVersion,
    this.releasePublishedDate
  });

  factory Repository.fromJSON(dynamic json) {

    final value = DynamicValue(json);

    return Repository(
      idGit: value['id'].toInt,
      name: value['name'].toString(),
      link: value['svn_url'].toString(),
      owner: value['owner']['login'].toString(),
      lastUpdate:  value['pushed_at'].toString(),
      createdDate:  value['created_at'].toString(),
     );
  }

  @override
  String toString() {
    return 'Repository{id: $id, idGit: $idGit, name: $name, owner: $owner, link: $link, lastUpdate: $lastUpdate, createdDate: $createdDate, releaseLink: $releaseLink, releaseVersion: $releaseVersion, releasePublishedDate: $releasePublishedDate}';
  }
}