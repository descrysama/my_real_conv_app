import 'dart:io';

import "package:cloud_firestore/cloud_firestore.dart";
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as fba;
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;

class ConversationService {
  static Stream<QuerySnapshot> getAll(uid) {
    return FirebaseFirestore.instance
        .collection('conversations')
        .where('between', arrayContains: uid)
        .snapshots();
  }

  static Stream<QuerySnapshot> getMessagesFromConversation(chatId) {
    return FirebaseFirestore.instance
        .collection('messages')
        .orderBy("created_at", descending: false)
        .snapshots();
  }

  static Future<String> getUserEmail(uid) async {
    var url = Uri.parse('http://10.0.10.216:5500/getuserbyuid');
    var response = await http.post(url, body: {'id': uid});

    final Map<String, dynamic> data = json.decode(response.body);
    final String email = data["email"];
    return email;
  }

  static Future<String> createNewConversation(userid, targetid) async {
    var url = Uri.parse('http://10.0.10.216:5500/createconversation');
    var response = await http.post(url, 
      headers: {"Content-Type": "application/json"},
      body: json.encode({"between": [userid, targetid]})
    );

    final Map<String, dynamic> data = json.decode(response.body);
    final String uid = data["uid"];
    return uid;
  }
}
