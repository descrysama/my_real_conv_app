import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_real_conv_app/pages/ChatDetailPage.dart';
import 'package:firebase_auth/firebase_auth.dart' as fba;
import 'package:my_real_conv_app/pages/CreateConversationList.dart';
import '../services/ConversationService.dart' show ConversationService;
import 'dart:convert';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  // ignore: library_private_types_in_public_api
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              const DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.blueGrey,
                  ),
                  child: Text("Messagerie Simplon",
                      textAlign: TextAlign.left,
                      style: TextStyle(fontSize: 18, color: Colors.white))),
              ListTile(
                title: const Text('Conversations'),
                onTap: () {
                  Navigator.pushNamed(context, '/', arguments: '');
                },
              ),
              ListTile(
                title: const Text('Deconnexion',
                    style: TextStyle(fontSize: 18, color: Colors.red)),
                onTap: () {
                  fba.FirebaseAuth.instance.signOut();
                  Navigator.pushReplacementNamed(context, '/sign-in');
                },
              )
            ],
          ),
        ),
        appBar: AppBar(
          title:
              Text(widget.title, style: const TextStyle(color: Colors.white)),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              StreamBuilder<QuerySnapshot>(
                stream: ConversationService.getAll(
                    fba.FirebaseAuth.instance.currentUser?.uid),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    final documents = snapshot.data!.docs;
                    if (documents.isNotEmpty) {
                      List<Future<Widget>> widgetFutures = [];
                      for (var document in documents) {
                        widgetFutures.add(buildWidget(document, context));
                      }
                      return FutureBuilder<List<Widget>>(
                        future: Future.wait(widgetFutures),
                        builder: (context, snapshot) {
                          final widgets = snapshot.data;
                          if (snapshot.connectionState ==
                                  ConnectionState.done &&
                              widgets != null) {
                            return Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: widgets,
                            );
                          } else {
                            return const Padding(
                              padding: EdgeInsets.all(
                                  10.0), //apply padding to all four sides
                              child: CircularProgressIndicator(),
                            );
                          }
                        },
                      );
                    } else {
                      return const Padding(
                        padding: EdgeInsets.all(
                            10.0), //apply padding to all four sides
                        child: Text(
                          "Aucune conversation. Créez en une.",
                          style: TextStyle(fontSize: 20),
                        ),
                      );
                    }
                  }
                  if (snapshot.hasError) {
                    return const Text("Une erreur est survenue");
                  }
                  return const Padding(
                    padding:
                        EdgeInsets.all(10.0), //apply padding to all four sides
                    child: Text(
                      "Chargement...",
                      style: TextStyle(fontSize: 25),
                    ),
                  );
                },
              )
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CreateConversationList()));
          },
          child: const Icon(Icons.add),
        ));
  }
}

Future<Widget> buildWidget(DocumentSnapshot document, context) async {
  final String documentId = document.id;
  final data = document.data() as Map<String, dynamic>;

  List<dynamic> between = data["between"] as List<dynamic>;

  String? currentUserUID = fba.FirebaseAuth.instance.currentUser?.uid;

  String text = "";

  if (!data.containsKey("name")) {
    for (var item in between) {
      if (item != currentUserUID) {
        String data = await ConversationService.getUserEmail(item);
        text = data;
      }
    }
  } else {
    text = data["name"];
  }

  return InkWell(
    onTap: () {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  ChatDetailPage(chatId: documentId, email: text)));
    },
    child: Ink(
      padding: const EdgeInsets.all(10.0),
      child: Center(
          child: ListTile(
              title: Text(
        text ?? "unknown user[]",
        textAlign: TextAlign.left,
        style: const TextStyle(fontSize: 20),
      ))),
    ),
  );
}
