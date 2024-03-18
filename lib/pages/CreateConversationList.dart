import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_real_conv_app/pages/ChatDetailPage.dart';
import 'package:firebase_auth/firebase_auth.dart' as fba;
import 'package:my_real_conv_app/services/ConversationService.dart';
import 'package:my_real_conv_app/services/UserService.dart';
import '../services/UserService.dart' show UserService;
import 'dart:convert';

class CreateConversationList extends StatefulWidget {
  const CreateConversationList({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CreateConversationListState createState() => _CreateConversationListState();
}

class _CreateConversationListState extends State<CreateConversationList> {
  List<dynamic> userList = [];
  @override
  void initState() {
    super.initState();
    fetchUserList();
  }

  Future<void> fetchUserList() async {
    try {
      Map<String, dynamic> userData = await UserService.getUserList(
          fba.FirebaseAuth.instance.currentUser?.uid);
      if (userData.containsKey('users')) {
        setState(() {
          userList = userData['users'];
        });
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Choisissez un nouveau destinataire',
              style: TextStyle(fontSize: 15)),
        ),
        body: userList.isEmpty
            ? Center(child: CircularProgressIndicator())
            : Ink(
                padding: const EdgeInsets.all(10.0),
                child: ListView.builder(
                  itemCount: userList.length,
                  itemBuilder: (context, index) {
                    if (fba.FirebaseAuth.instance.currentUser?.uid !=
                        userList[index]["uid"]) {
                      return InkWell(
                        onTap: () async{
                          final getCreatedConversationId = await ConversationService.createNewConversation(fba.FirebaseAuth.instance.currentUser?.uid, userList[index]["uid"]);
                          // ignore: use_build_context_synchronously
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ChatDetailPage( chatId: getCreatedConversationId, email: userList[index]["email"])));
                        },
                        child: Ink(
                          padding: const EdgeInsets.all(10.0),
                          child: Center(
                              child: ListTile(
                            title: Text(userList[index]['email']),
                          )),
                        ),
                      );
                    }
                    return null;
                  },
                ),
              ));
  }
}
