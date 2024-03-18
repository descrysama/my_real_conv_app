import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/ConversationService.dart' show ConversationService;
import 'package:firebase_auth/firebase_auth.dart' as fba;
import 'package:image_picker/image_picker.dart';

class ChatDetailPage extends StatefulWidget {
  ChatDetailPage(
      {Key? key,
      required this.chatId,
      required this.email})
      : super(key: key);
  final String chatId;
  final String email;

  @override
  // ignore: library_private_types_in_public_api
  _ChatDetailPageState createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {

  late File _image;
  final picker = ImagePicker();
  Future getImageFromGallery() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

//Image Picker function to get image from camera
  Future getImageFromCamera() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  @override
  build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
          appBar: AppBar(
              title: Text(widget.email,
                  style: const TextStyle(color: Colors.white))),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                StreamBuilder<QuerySnapshot>(
                  stream: ConversationService.getMessagesFromConversation(
                      widget.chatId),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasData) {
                      final documents = snapshot.data!.docs;
                      if (documents.isNotEmpty) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: documents.map((document) {
                            final data =
                                document.data() as Map<String, dynamic>;
                            return MessageWidget(data);
                          }).toList(),
                        );
                      } else {
                        return const Text('Commencez la conversation');
                      }
                    }
                    if (snapshot.hasError) {
                      return const Text("Une erreur est survenue");
                    }
                    return const Text("Chargement...");
                  },
                ),
                Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: SizedBox(
                        width: screenHeight * 0.5,
                        child: const TextField(
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: "Ecrivez un message"),
                        ),
                      ),
                    ))
              ],
            ),
          )),
    );
  }
}

Widget MessageWidget(data) {
  var textContent =
      fba.FirebaseAuth.instance.currentUser?.uid == data["sender_id"]
          ? Container(
              padding: const EdgeInsets.all(4.2),
              margin: const EdgeInsets.all(5),
              color: Colors.green,
              height: 50,
              child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    data["message"],
                    textAlign: TextAlign.left,
                    style: const TextStyle(fontSize: 18),
                  )),
            )
          : Container(
              padding: const EdgeInsets.all(4.2),
              margin: const EdgeInsets.all(5),
              color: Colors.blue,
              height: 50,
              width: double.infinity,
              child: Text(
                data["message"],
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 18),
              ),
            );

  return GestureDetector(child: Container(height: 60, child: textContent));
}
