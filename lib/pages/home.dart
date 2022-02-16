import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:git_repo_watcher/classes/repository.dart';
import 'package:git_repo_watcher/pages/new_repository.dart';
import 'package:git_repo_watcher/pages/pg_settings.dart';
import 'package:git_repo_watcher/widgets/repository_card.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {

  //API para dados do REPO
  //https://api.github.com/repos/Fschmatz/todo_fschmatz

  Repository repo = Repository(name: 'x',id: 2, link: 'ssadas');

  @override
  void initState() {
    super.initState();
    getRepository();
  }

  Future<void> getRepository() async {
    final response = await http
        .get(Uri.parse('https://api.github.com/repos/Fschmatz/todo_fschmatz'));

    if (response.statusCode == 200) {
      //print(response.body.toString());

      setState(() {
        repo = Repository.fromJSON(jsonDecode(response.body));
      });




      print( repo.toString());


    } else {

      throw Exception('Failed to load album');
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          title: const Text('Git Repo Watcher'),
          actions: [
            IconButton(
                icon: const Icon(
                  Icons.add_outlined,
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) => const NewRepository(),
                        fullscreenDialog: true,
                      ));
                }),
            const SizedBox(
              width: 8,
            ),
            IconButton(
                icon: const Icon(
                  Icons.settings_outlined,
                ),
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (BuildContext context) => PgSettings(),
                        fullscreenDialog: true,
                      ));
                }),
          ],
        ),
        body: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: 10,
                itemBuilder: (context, index) {
                  return RepositoryCard(
                    key: UniqueKey(),
                    repository: repo
                  );
                },
              ),
              const SizedBox(
                height: 50,
              )
            ]),
        );
  }
}
