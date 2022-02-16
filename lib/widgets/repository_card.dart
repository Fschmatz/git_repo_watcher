import 'package:flutter/material.dart';
import 'package:git_repo_watcher/classes/repository.dart';

class RepositoryCard extends StatefulWidget {

  Repository repository;

  RepositoryCard({Key? key, required this.repository}) : super(key: key);

  @override
  _RepositoryCardState createState() => _RepositoryCardState();
}

class _RepositoryCardState extends State<RepositoryCard> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 5),
      child: Card(
        child: ListTile(
          title: Text(widget.repository.name!),
          subtitle: Text(widget.repository.link!),
        ),
      ),
    );
  }
}
