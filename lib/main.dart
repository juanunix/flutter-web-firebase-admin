import 'dart:html';
import 'package:firebase/firebase.dart';
import 'package:flutter_web/material.dart';
import 'firebase_helper.dart';

Database database = FirebaseHelper.initDatabase();

void main() {
  runApp(FirebaseApp());
}

class FirebaseApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firebase Admin',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: FirebaseHome(),
    );
  }
}

_startFilePicker() async {
  InputElement uploadInput = FileUploadInputElement();
  uploadInput.click();

  uploadInput.onChange.listen((e) {
    // read file content as dataURL
    final files = uploadInput.files;
    if (files.length == 1) {
      final file = files[0];
      final reader = FileReader();

      reader.onLoadEnd.listen((e) {
        // _handleResult(reader.result);
      });
      reader.readAsDataUrl(file);
    }
  });
}

class FirebaseHome extends StatefulWidget {
  @override
  _FirebaseHomeState createState() => _FirebaseHomeState();
}

class _FirebaseHomeState extends State<FirebaseHome> {
  var databaseRef = database.ref("my_database").child("my_data");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text("A Demo Flutter Web Firebase Admin"),
        ),
      ),
      body: StreamBuilder(
        stream: databaseRef.onValue,
        builder: (BuildContext context, snap) {
          if (!snap.hasError && snap.hasData) {
            DataSnapshot snapshot = snap.data.snapshot;
            if (snapshot.hasChildren()) {
              List snapList = Map.from(snapshot.val()).values.toList();

              return ListView.builder(
                itemCount: snapList.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                    child: ListTile(
                      leading: IconButton(
                        onPressed: () {
                          editOrDeleteDataDialog(context, snapList[index]);
                        },
                        icon: Icon(
                          Icons.edit,
                        ),
                      ),
                      trailing: IconButton(
                        onPressed: () {
                          databaseRef.child(snapList[index]["id"]).remove();
                        },
                        icon: Icon(
                          Icons.delete_forever,
                          color: Colors.red,
                        ),
                      ),
                      title: Text(snapList[index]['text'].toString()),
                    ),
                  );
                },
              );
            } else {
              return Center(
                child: Text(
                  "No Data Available...!",
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                ),
              );
            }
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          createDataDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  createDataDialog(BuildContext context) {
    TextEditingController nameController = TextEditingController();
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Add Data"),
            content: TextField(
              controller: nameController,
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Cancel"),
              ),
              FlatButton(
                onPressed: () {
                  String key = databaseRef.push().key;
                  databaseRef
                      .child(key)
                      .set({"text": nameController.text, "id": key});
                  Navigator.pop(context);
                },
                child: Text("Add"),
              ),
            ],
          );
        });
  }

  editOrDeleteDataDialog(BuildContext context, oldData) {
    TextEditingController nameController =
        TextEditingController(text: oldData["text"]);
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Add Data"),
            content: TextField(
              controller: nameController,
            ),
            actions: <Widget>[
              FlatButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Cancel"),
              ),
              FlatButton(
                onPressed: () {
                  databaseRef
                      .child(oldData["id"])
                      .set({"text": nameController.text, "id": oldData["id"]});
                  Navigator.pop(context);
                },
                child: Text("Update"),
              )
            ],
          );
        });
  }
}
