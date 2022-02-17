import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:git_repo_watcher/classes/repository.dart';
import 'package:git_repo_watcher/pages/edit_repository.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class RepositoryCard extends StatefulWidget {
  Repository repository;

  RepositoryCard({Key? key, required this.repository}) : super(key: key);

  @override
  _RepositoryCardState createState() => _RepositoryCardState();
}

class _RepositoryCardState extends State<RepositoryCard> {
  Repository repo = Repository(id: null, name: '', link: '');
  String repoApi = 'https://api.github.com/repos/';
  bool loadingData = true;
  List<String> formattedRepositoryData = [];

  String savedLink = '';

  @override
  void initState() {
    super.initState();
    formattedRepositoryData = widget.repository.link!.split('/');
    getRepositoryData();
  }


  Future<void> getRepositoryData() async {
    final response = await http.get(Uri.parse("https://api.github.com/repos/" +
        formattedRepositoryData[3] +
        "/" +
        formattedRepositoryData[4]));

    print("https://api.github.com/repos/" +
        formattedRepositoryData[3] +
        "/" +
        formattedRepositoryData[4]);
    print(response.statusCode.toString());

    if (response.statusCode == 200) {
      if (mounted) {
        setState(() {
          loadingData = false;
          repo = Repository.fromJSON(jsonDecode(response.body));
        });
      }
    } else if (response.statusCode == 403) {
      Fluttertoast.showToast(
        msg: "API Limit",
      );
    }
    else if (response.statusCode == 404) {
      repo.name = "Link Error";
      setState(() {
        loadingData = false;
        repo;
      });
      Fluttertoast.showToast(
        msg: "Error Loading",
      );
    } else {
      Fluttertoast.showToast(
        msg: "Error Loading",
      );
    }
  }

  _launchPage() {
    String url = widget.repository.link!;
    launch(url);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: _launchPage,
          onLongPress: () {
            Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => EditRepository(repository: widget.repository),
                  fullscreenDialog: true,
                ));
          },
          child: ListTile(
            title: loadingData ? const Text(' ') : Text(repo.name!),
            subtitle: loadingData ? const Text(' ') : Text(repo.link!),
          ),
        ),
      ),
    );
  }
}
