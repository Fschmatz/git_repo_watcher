import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../db/repository_dao.dart';
import '../widgets/dialog_alert_error.dart';

class NewRepository extends StatefulWidget {
  @override
  _NewRepositoryState createState() => _NewRepositoryState();

  const NewRepository({Key? key}) : super(key: key);
}

class _NewRepositoryState extends State<NewRepository> {

  final _categories = RepositoryDao.instance;
  TextEditingController customControllerName = TextEditingController();

  void _saveTag() async {
    Map<String, dynamic> row = {
      RepositoryDao.columnName: customControllerName.text,
      //RepositoryDao.columnColor: currentColor.toString(),
    };
    final id = await _categories.insert(row);
  }

  String checkForErrors() {
    String errors = "";
    if (customControllerName.text.isEmpty) {
      errors += "Name is empty\n";
    }
    return errors;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
            child: IconButton(
              tooltip: 'Save',
              icon: const Icon(
                Icons.save_outlined,
              ),
              onPressed: () async {
                String errors = checkForErrors();
                if (errors.isEmpty) {
                  _saveTag();
                  Navigator.of(context).pop();
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return  dialogAlertErrors(errors,context);
                    },
                  );
                }
              },
            ),
          )
        ],
        title: const Text('New Tag'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const SizedBox(
              height: 0.1,
            ),
            title: Text("Name".toUpperCase(),
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.secondary)),
          ),
          ListTile(
            leading: const Icon(
              Icons.notes_outlined,
            ),
            title: TextField(
              autofocus: true,
              minLines: 1,
              maxLength: 30,
              maxLengthEnforcement: MaxLengthEnforcement.enforced,
              controller: customControllerName,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                border: InputBorder.none,
                counterText: "",
                helperText: "* Required",
              ),
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),

        ],
      ),
    );
  }
}
