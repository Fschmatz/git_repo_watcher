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

  factory Repository.fromMap(Map<String, dynamic> map) {
    return Repository(
      id: map['id'],
      name: map['name'],
      note: map['note'],
      link: map['link'],
      idGit: int.parse(map['idGit']),
      owner: map['owner'],
      lastUpdate: map['lastUpdate'],
      defaultBranch: map['defaultBranch'],
      releaseLink: map['releaseLink'],
      releaseVersion: map['releaseVersion'],
      releasePublishedDate: map['releasePublishedDate'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'note': note,
      'link': link,
      'idGit': idGit.toString(),
      'owner': owner,
      'lastUpdate': lastUpdate,
      'defaultBranch': defaultBranch,
      'releaseLink': releaseLink,
      'releaseVersion': releaseVersion,
      'releasePublishedDate': releasePublishedDate,
    };
  }
}
