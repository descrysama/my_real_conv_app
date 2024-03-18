import 'dart:io';

import "package:cloud_firestore/cloud_firestore.dart";
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as fba;
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;

class UserService {
  static Future<Map<String,dynamic>> getUserList(uid) async {
    var url = Uri.parse('http://10.0.10.216:5500/getusers/$uid');
    var response = await http.get(url);
    final Map<String, dynamic> data = json.decode(response.body);
    return data;
  }
}
