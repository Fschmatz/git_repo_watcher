import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../db/repository_dao.dart';
import '../../util/utils_functions.dart';
import '../classes/repository.dart';
import '../widgets/dialog_alert_error.dart';

class EditCategory extends StatefulWidget {

  @override
  _EditCategoryState createState() => _EditCategoryState();

  Repository repository;
  EditCategory({Key? key,required this.repository}) : super(key: key);
}

class _EditCategoryState extends State<EditCategory> {

  final _categories = RepositoryDao.instance;
  TextEditingController customControllerName = TextEditingController();


  @override
  void initState() {
    super.initState();
    //customControllerName.text = widget.repository.name;
  }

  void _updateTag() async {
    Map<String, dynamic> row = {
      RepositoryDao.columnId: widget.repository.id,
      RepositoryDao.columnName: customControllerName.text,

    };
    final update = await _categories.update(row);
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
                  _updateTag();
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
