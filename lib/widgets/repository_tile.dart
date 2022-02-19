import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:git_repo_watcher/classes/repository.dart';
import 'package:git_repo_watcher/pages/edit_repository.dart';
import 'package:http/http.dart' as http;
import 'package:jiffy/jiffy.dart';
import 'package:url_launcher/url_launcher.dart';

import '../db/repository_dao.dart';

class RepositoryTile extends StatefulWidget {
  Repository repository;

  RepositoryTile({Key? key, required this.repository}) : super(key: key);

  @override
  _RepositoryTileState createState() => _RepositoryTileState();
}

class _RepositoryTileState extends State<RepositoryTile> {
  Repository repo = Repository(
      id: null,
      owner: '',
      createdDate: '',
      link: '',
      name: '',
      lastUpdate: '',
      idGit: null);
  String repoApi = 'https://api.github.com/repos/';
  bool loadingData = false;
  List<String> formattedRepositoryData = [];

  String savedLink = '';

  @override
  void initState() {
    super.initState();
    formattedRepositoryData = widget.repository.link!.split('/');
    repo = widget.repository;
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
    } else if (response.statusCode == 404) {
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

  void openBottomMenu() {
    showModalBottomSheet(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(25.0), topRight: Radius.circular(25.0)),
        ),
        isScrollControlled: true,
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
              child: Wrap(
                children: <Widget>[
                  ListTile(
                    leading: const Icon(Icons.open_in_new_outlined),
                    title: const Text(
                      "Open in browser",
                      style: TextStyle(fontSize: 16),
                    ),
                    onTap: () {
                      _launchPage();
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.edit_outlined),
                    title: const Text(
                      "Edit",
                      style: TextStyle(fontSize: 16),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                    /*  Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) =>
                                EditRepository(repository: widget.repository),
                            fullscreenDialog: true,
                          ));*/
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.delete_outline_outlined),
                    title: const Text(
                      "Delete",
                      style: TextStyle(fontSize: 16),
                    ),
                    onTap: () {
                      showAlertDialogOkDelete(context);
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future<void> _delete() async {
    final repositories = RepositoryDao.instance;
    final deleted = await repositories.delete(widget.repository.id!);
  }

  showAlertDialogOkDelete(BuildContext context) {
    Widget okButton = TextButton(
      child: Text(
        "Yes",
        style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).accentColor),
      ),
      onPressed: () {
        Navigator.of(context).pop();
        _delete();
      },
    );

    AlertDialog alert = AlertDialog(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      title: const Text(
        "Confirm", //
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
      ),
      content: const Text(
        "\nDelete ?",
        style: TextStyle(
          fontSize: 18,
        ),
      ),
      actions: [
        okButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: openBottomMenu,
      onLongPress: getRepositoryData,
      child: Column(
        children: [
          ListTile(
            title: Text(repo.name!,style: const TextStyle(fontWeight: FontWeight.w600),),
            subtitle: Text(repo.owner!),
          ),
         /* const ListTile(
            title: Text("Latest release"),
            trailing: const Text("06/06/2666"),
          ),*/
          Row(
            children: [
             /* Expanded(
                child: ListTile(
                  title: const Text("Creation date"),
                  //trailing: Text(repo.createdDate!),
                  subtitle: Text(repo.createdDate!),
                ),
              ),*/

              Expanded(
                child: ListTile(
                  title: const Text("Last update"),

                  //Jiffy(data).format("dd/MM/yyyy"),

                  subtitle: Text(Jiffy(repo.lastUpdate!).format("dd/MM/yyyy"))
                  //trailing: Text(repo.lastUpdate!),
                ),
              ),
              const Expanded(
                child: ListTile(
                  title: Text("Latest release"),
                  subtitle: Text("06/06/2666"),
                  //trailing: Text(repo.lastUpdate!),
                ),
              ),
            ],
          ),


        ],
      ),
    );
  }
}
