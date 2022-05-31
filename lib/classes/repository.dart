import 'package:dynamic_value/dynamic_value.dart';

class Repository {
  int? id;
  int? idGit;
  String? name;
  String? note;
  String? owner;
  String? link;
  String? lastUpdate;
  String? defaultBranch;
  String? releaseLink;
  String? releaseVersion;
  String? releasePublishedDate;

  Repository(
      {this.id,
      required this.idGit,
      required this.name,
      this.note,
      required this.link,
      required this.owner,
      required this.lastUpdate,
      required this.defaultBranch,
      this.releaseLink,
      this.releaseVersion,
      this.releasePublishedDate});

  factory Repository.fromJSON(dynamic json) {
    final value = DynamicValue(json);

    return Repository(
      idGit: value['id'].toInt,
      name: value['name'].toString(),
      link: value['svn_url'].toString(),
      owner: value['owner']['login'].toString(),
      lastUpdate: value['pushed_at'].toString(),
      defaultBranch: value['default_branch'].toString(),
    );
  }

}
